# IAM STS

- [AWS Secret](https://www.vaultproject.io/docs/secrets/aws)
- [STS Federation Tokens](https://www.vaultproject.io/docs/secrets/aws#sts-federation-tokens)
- [STS AssumeRole](https://www.vaultproject.io/docs/secrets/aws#sts-assumerole)

## How to Create AWS IAM with Vault

1. IAM User
   - cons
      - Random name of IAM User
      - No session expiration time.
      - Manual Deletion
2. FederationToken
   - pros: Security token up to 12 hours.
   - cons: Can have the authority of the token creator as it is.
3. AssumeRole
   - pros
      - The setup is complicated and safe.
      - More functions than FederationToken.
      - Supports cross-account authentication.
      - Security token up to 1 hours.

---

## Contents

1. Vault Secret Engine
   1. New AWS IAM User: `vault`
   1. `vault` user policy
   1. ~~Create a IAM User~~. Difficult to manage after creation.
1. FederationToken
   1. `vault` user policy: `VaultFederationPolicy`
   1. Create a FederationToken
1. AssumeRole
   1. S3 user role
      1. S3 user policy: `VaultS3GetObjectPolicy`
      1. S3 user role: `VaultS3ReaderRole`
      1. IAM User trusted relationship: Grant `AssumeRole` to `vault`
   1. `vault` user policy: `VaultAssumeS3ReaderPolicy`
   1. (option) S3's bucket policy
   1. Create: AssumeRole

---

## Secret Engine

```bash
vault secrets enable aws
```

### Create IAM User to create AssuleRole

Create a User for Vault's aws secret engine in AWS IAM.

- name: `vault`
- access type: programmatic access
- role: none

Check the access key and secret key.

ARN: `arn:aws:iam::883545701064:user/vault`

### Secret engine settings

Enter the access key and secret key of the `vault` user.

### Create policy

The `vault` user should manage IAM users dynamically.

Create the following policy and add it to your vault.

#### VaultDynamicIAMPolicy

```json
{
  "Version": "2012-10-17",
  "Statement": [
  {
    "Sid": "VisualEditor0",
    "Effect": "Allow",
    "Action": [
      "iam:DeleteAccessKey",
      "iam:AttachUserPolicy",
      "iam:DeleteUserPolicy",
      "iam:DeleteUser",
      "iam:ListUserPolicies",
      "iam:CreateUser",
      "iam:CreateAccessKey",
      "iam:RemoveUserFromGroup",
      "iam:AddUserToGroup",
      "iam:ListGroupsForUser",
      "iam:PutUserPolicy",
      "iam:ListAttachedUserPolicies",
      "iam:DetachUserPolicy",
      "iam:ListAccessKeys"
    ],
    "Resource": [
      "arn:aws:iam::xxxxxxxxxxxx:user/vault-*",
      "arn:aws:iam::xxxxxxxxxxxx:group/vault-group"
    ]
  }
  ]
}
```

---

## FederationToken

### Add a policy

`VaultFederationPolicy`: `arn:aws:iam::xxxxxxxxxxxx:policy/VaultFederationPolicy`

Add the `vault` user.

```json
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "s3:GetObject",
                "sts:GetFederationToken"
            ],
            "Resource": [
                "arn:aws:s3:::samples-for-vault/*",
                "arn:aws:sts::xxxxxxxxxxxx:federated-user/vault-*"
            ]
        }
    ]
}
```

### Vault

#### Add a Role

Temporarily grant a role that can read files in the S3 bucket.

- Role name: `vault-s3reader-with-federation-token`
- Credential type: `Federation Token`
- Policy:

```json
{
  "Version": "2012-10-17",
  "Statement": {
    "Action": [
      "s3:GetObject"
    ],
    "Effect": "Allow",
    "Resource": "arn:aws:s3:::samples-for-vault/*"
  }
}
```

#### Credential

- TTL: 15m ~ 12h
  - DurationSeconds: 900s ~ 43200s

Copy Access Key, Secret Key and Security Token.

---

## AssumeRole

### Add a S3 user policy

Create a policy that can only import objects.

`VaultS3GetObjectPolicy`: `arn:aws:iam::xxxxxxxxxxxx:policy/VaultS3GetObjectPolicy`

```json
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": "s3:GetObject",
            "Resource": "arn:aws:s3:::samples-for-vault/*"
        }
    ]
}
```

### Add a S3 User Role

Create a role with the policy.

`VaultS3ReaderRole`: `arn:aws:iam::xxxxxxxxxxxx:role/VaultS3ReaderRole`

```json
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "VisualEditor0",
            "Effect": "Allow",
            "Action": "s3:GetObject",
            "Resource": "arn:aws:s3:::samples-for-vault/*"
        }
    ]
}
```

#### Add trust relationship

Set as the `vault` user as the trust relationship of the role.

```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "AWS": "arn:aws:iam::xxxxxxxxxxxx:user/vault"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
```

### Add a Policy

`VaultAssumeS3ReaderPolicy`: `arn:aws:iam::xxxxxxxxxxxx:policy/VaultAssumeS3ReaderPolicy`

Add a policy to the `vault` user.

```json
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": "sts:AssumeRole",
            "Resource": "arn:aws:iam::xxxxxxxxxxxx:role/VaultS3ReaderRole"
        }
    ]
}
```

### Set S3 Bucket

```json
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Principal": {
                "AWS": "arn:aws:iam::xxxxxxxxxxxx:role/VaultS3ReaderRole"
            },
            "Action": "s3:GetObject",
            "Resource": "arn:aws:s3:::samples-for-vault/*"
        }
    ]
}
```

### Vault

#### New Role

Temporarily grant a role that can read files in the S3 bucket.

- Role name: `vault-s3reader-with-assume-role`
- Credential type: `Assumed Role`
- Role ARNs: `arn:aws:iam::xxxxxxxxxxxx:role/VaultS3ReaderRole`

#### Credential 생성

- TTL: 15m ~ 1h
  - DurationSeconds: 900s ~ 3600s

Copy Access Key, Secret Key and Security Token.

---

## Python Client

[Example codes](../hvac)

1. Generate STS with Vault Client Library hvac
1. Read S3 Object with AWS SDK boto3

### Directory

- `.env`
  - `VAULT_ADDR`: `https://vault`
  - `ROLE_NAME`: `vault-s3reader-with-assume-role` / `vault-s3reader-with-federation-token`
  - `TTL`: `900`
  - `BUCKET_NAME`: `samples-for-vault`
  - `KEY`: `hello.txt`
- `aws_token.py`
- `s3_object.py`
- `credentials.json`

### Install libraries

```bash
pip install -r requirements.txt
```

or

```bash
pip install hvac # Vault python client library
pip install python-decouple # dotenv library
pip install boto3 # AWS SDK python library
```

### Usages

#### Create token file

Create a `./credentials.json` file containing the session token.

```bash
python aws_token.py
```

#### Read S3 Object

Use `./credentials.json` to access S3.

```bash
python s3_object.py
```

### How to handle enterprise SSL certificates

```bash
cp /Users/$USER/.pyenv/versions/hvac/lib/python3.9/site-packages/certifi/cacert.pem ./ca-trust
cat ./ca-trust/enterprise.crt >> ./ca-trust/cacert.pem

export REQUESTS_CA_BUNDLE=./ca-trust/cacert.pem
```
