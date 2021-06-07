# Generates database credentials dynamically for the PostgreSQL

1. Prepare vault and postgresql
1. [Generates database credentials dynamically for the PostgreSQL](#postgresql-database-secrets-engine)
1. [Root Credential Rotation](#root-credential-rotation)

Documentations:
- [Dynamic Secrets: Database Secrets Engine](https://learn.hashicorp.com/tutorials/vault/database-secrets)
- [PostgreSQL Database Secrets Engine](https://www.vaultproject.io/docs/secrets/databases/postgresql)
- [Database Static Roles and Credential Rotation](https://learn.hashicorp.com/tutorials/vault/database-creds-rotation)
- [Database Root Credential Rotation](https://learn.hashicorp.com/tutorials/vault/database-root-rotation)

---

## Prepare

### Use VM with docker

in host:

[Local VM Provision](../local-vm/README.md): install vault in local vm

```bash
cd local-vm
```

Enable Docker Provisioner in `Vagrantfile`:

```ruby
config.vm.provision "docker"
```

Start VM:

```bash
vagrant up
vagrant ssh
```

And Unseal Vault: [how to unseal vault](../local-vm/README.md#unseal-vault)

### Start postgresql on docker

in guest:

```bash
docker run --rm --name my-postgres -e POSTGRES_PASSWORD=mysecretpassword -p 5432:5432 -d postgres
```

### Install postgresql client in ubuntu

in guest:

```bash
sudo sh -c 'echo "deb http://apt.postgresql.org/pub/repos/apt $(lsb_release -cs)-pgdg main" > /etc/apt/sources.list.d/pgdg.list'
wget --quiet -O - https://www.postgresql.org/media/keys/ACCC4CF8.asc | sudo apt-key add -
sudo apt-get update
sudo apt-get -y install postgresql-client-12
```

---

## PostgreSQL Database Secrets Engine

Vault: [documentation](https://www.vaultproject.io/docs/secrets/databases/postgresql)

### Login in Guest

in host:

```bash
export VAULT_ADDR="http://127.0.0.1:8200"
export VAULT_TOKEN="ROOT_TOKEN"
```

### Enable database secretes engine

in host:

```bash
vault secrets enable database
```

[http://192.168.82.82:8200/ui/vault/secrets/database/overview](http://192.168.82.82:8200/ui/vault/secrets/database/overview)

### Configure Vault

in host:

```bash
vault write database/config/my-postgresql-database \
    plugin_name=postgresql-database-plugin \
    allowed_roles="my-role" \
    connection_url="postgresql://{{username}}:{{password}}@localhost:5432/postgres?sslmode=disable" \
    username="postgres" \
    password="mysecretpassword"
```

### Configure a dynamic role

in host:

```bash
vault write database/roles/my-role \
    db_name=my-postgresql-database \
    creation_statements="CREATE ROLE \"{{name}}\" WITH LOGIN PASSWORD '{{password}}' VALID UNTIL '{{expiration}}'; \
        GRANT SELECT ON ALL TABLES IN SCHEMA public TO \"{{name}}\";" \
    default_ttl="1h" \
    max_ttl="24h"
```

### Usages

in host:

```bash
vault read database/creds/my-role
```

```bash
Key                Value
---                -----
lease_id           database/creds/my-role/Uf57dgFjDa3oYmuAayixV1Kr
lease_duration     1h
lease_renewable    true
password           D1KDJ-nj4R5msl9ICHxv
username           v-root-my-role-C0sEk8YJziknNm3cOmRj-1623052447
```

#### Test Login

In guest:

```bash
psql -h localhost -p 5432 -d postgres -W -U v-root-my-role-C0sEk8YJziknNm3cOmRj-1623052447
Password: D1KDJ-nj4R5msl9ICHxv
```

Create a table:

```sql
CREATE TABLE fruit (
   id serial PRIMARY KEY,
   name VARCHAR(50) UNIQUE NOT NULL,
   count INT NOT NULL
);
```

Insert data:

```sql
INSERT INTO fruit (name, count) 
VALUES ('apple', 3), ('banana', 5), ('kiwi', 8);
```

Read data:

```sql
SELECT * FROM fruit;
```

```sql
 id |  name  | count 
----+--------+-------
  1 | apple  |     3
  2 | banana |     5
  3 | kiwi   |     8
(3 rows)
```

Show tables:

```sql
\dt+

                            List of relations
 Schema | Name  | Type  |                     Owner                      
--------+-------+-------+------------------------------------------------
 public | fruit | table | v-root-my-role-C0sEk8YJziknNm3cOmRj-1623052447
(1 row)
```

---

## Root Credential Rotation

Vault: [documentation](https://learn.hashicorp.com/tutorials/vault/database-root-rotation)

### Policy

Add policy:

```ruby
# Mount secrets engines
path "sys/mounts/*" {
  capabilities = [ "create", "read", "update", "delete", "list" ]
}

# Configure the database secrets engine and create roles
path "database/*" {
  capabilities = [ "create", "read", "update", "delete", "list" ]
}
```

### Enable the database secrets engine

in host:

```bash
vault secrets enable database
```

### Configure PostgreSQL secrets engine

in host:

Use root username and root password:

```bash
vault write database/config/my-postgresql-database-for-root \
    plugin_name=postgresql-database-plugin \
    allowed_roles="*" \
    connection_url="postgresql://{{username}}:{{password}}@localhost:5432/postgres?sslmode=disable" \
    username="postgres" \
    password="mysecretpassword"
```

### Rotate the root credentials

```bash
vault write -force database/rotate-root/my-postgresql-database-for-root
```

### Verify login with previous root password

In guest:

```bash
psql -h localhost -p 5432 -d postgres -U postgres -W
Password: mysecretpassword
```

`psql: error: FATAL:  password authentication failed for user "postgres"`

### Verify the configuration

in host:

SQL file: [readonly.sql](readonly.sql)

```sql
CREATE ROLE "{{name}}" WITH LOGIN PASSWORD '{{password}}' VALID UNTIL '{{expiration}}';
GRANT SELECT ON ALL TABLES IN SCHEMA public TO "{{name}}";
```

```bash
vault write database/roles/readonly db_name=my-postgresql-database-for-root \
    creation_statements=@readonly.sql \
    default_ttl=1h max_ttl=24h
```

Get a new credentials:

```bash
vault read database/creds/readonly
```

```bash
Key                Value
---                -----
lease_id           database/creds/readonly/xvyoV25ZUXrTO4teHWXeic34
lease_duration     1h
lease_renewable    true
password           AioIHn-4V9y8YauOVph4
username           v-root-readonly-W2LoSvHJG8Tm50tVaMmr-1623054516
```

### Test Login as root

in guest:

```bash
psql -h localhost -p 5432 -d postgres -U v-root-readonly-W2LoSvHJG8Tm50tVaMmr-1623054516 -W
Password: AioIHn-4V9y8YauOVph4
```

```sql
\du

                                                      List of roles
                    Role name                    |                         Attributes                         | Member of 
-------------------------------------------------+------------------------------------------------------------+-----------
 postgres                                        | Superuser, Create role, Create DB, Replication, Bypass RLS | {}
 v-root-my-role-C0sEk8YJziknNm3cOmRj-1623052447  | Password valid until 2021-06-07 08:54:12+00                | {}
 v-root-readonly-W2LoSvHJG8Tm50tVaMmr-1623054516 | Password valid until 2021-06-07 09:28:41+00                | {}
```
