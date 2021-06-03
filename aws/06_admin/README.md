## Root

1. [https://vault.example.com/ui](https://vault.example.com/ui)
2. Login with Vault Root Key

### AWS IAM Login configuration

#### Policy

1. Menu: Policies
1. Create ACL policy
1. Name: `admin`
1. Contents: [admin.hcl](../policy/admin.hcl)

#### Enable AWS Secret Storage

1. Menu: Secrets
1. Enable new engine
1. AWS
1. Enable Engine

#### Access Method Configuration

1. Menu: Access
1. Authentication Methods: Enable new method
1. AWS
1. Next
1. Allowed passthrough request headers: `vault.example.com`
1. Enable Method

#### Default Role

When an AWS user logs in, default permissions are issued.

Click the terminal button in the upper right corner and enter the following command:

```bash
vault write auth/aws/role/dev auth_type=iam bound_iam_principal_arn='arn:aws:iam::xxxxxxxxxxxx:*' policies=default max_ttl=24h
```

#### Token Test

in Local Terminal

```bash
export VAULT_ADDR="https://vault.example.com"
# export AWS_PROFILE=<AWS-Profile>
```

##### Login with default policy

```bash
vault login -method=aws header_value=vault.example.com role=dev
```

##### Login with admin policy

```bash
vault write auth/aws/role/<AWS-User-ID> auth_type=iam bound_iam_principal_arn='arn:aws:iam::xxxxxxxxxxxx:user/<AWS-User-ID>' policies=admin max_ttl=24h
```

Vault 사용자는 다음 명령으로 토큰을 발급받는다:

```bash
vault login -method=aws header_value=vault.example.com
```

Log in `https://vault.example.com/ui` with token

---

## Remove root token

For security, the root token is invalidated after all settings are completed.

```bash
export VAULT_ADDR="https://vault.example.com"
export VAULT_TOKEN="Root Token"
```

Remove:

```bash
vault token revoke "Root Token"
```
