# AWS Resources

Prepare the resource manually.

### Key Pair

1. Create and download a key pair for Vault EC2.
   - name: `vault`

### Bastion Security Group

1. Bastion Security Group ID: `sg-xxxxxxxxxxxxxxxxx`
1. Register your IP in the inbound rule.
   - SSH 22
     - My IP

### Create a security group

1. EKS Security Group ID: `sg-xxxxxxxxxxxxxxxxx`
1. Create a Security Group: `Vault Security Group`
   - ID: `sg-xxxxxxxxxxxxxxxxx`
1. Add the inbound of the security group.
  - SSH 22
    - Bastion security group: `sg-xxxxxxxxxxxxxxxxx`
  - TCP 8200: anywhere
  - TCP 8201
    - Vault security group: `sg-xxxxxxxxxxxxxxxxx` (Vault Advertise)
   
### Add subnet to VPC

1. VPC ID: `vpc-xxxxxxxxxxxxxxxxx`
1. Create a new subnet in your VPC
   - Name: `Private Vault Subnet A`, `Private Vault Subnet B`
   - Availability Zone: Seoul `ap-northeast-2a`
   - IPv4 CIDR block: `10.xxx.xxx.xxx/24`
1. Change to `Private NAT Route Table`
   - Route Table ID: `rtb-xxxxxxxxxxxxxxxxx`
1. Check subnet IDs: `subnet-xxxxxxxxxxxxxxxxx`, `subnet-xxxxxxxxxxxxxxxxx`

### AWS KMS

KMS automatically manages the Vault Seal Key.

1. Create a customer managed key.
   - Type: `Symmetric`
   - Alias: `vault`
   - Key manager: your AWS ID

```json
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "Enable IAM User Permissions",
            "Effect": "Allow",
            "Principal": {
                "AWS": "arn:aws:iam::xxxxxxxxxxxx:root"
            },
            "Action": "kms:*",
            "Resource": "*"
        },
        {
            "Sid": "Allow access for Key Administrators",
            "Effect": "Allow",
            "Principal": {
                "AWS": "arn:aws:iam::xxxxxxxxxxxx:user/<your AWS ID>"
            },
            "Action": [
                "kms:Create*",
                "kms:Describe*",
                "kms:Enable*",
                "kms:List*",
                "kms:Put*",
                "kms:Update*",
                "kms:Revoke*",
                "kms:Disable*",
                "kms:Get*",
                "kms:Delete*",
                "kms:TagResource",
                "kms:UntagResource",
                "kms:ScheduleKeyDeletion",
                "kms:CancelKeyDeletion"
            ],
            "Resource": "*"
        }
    ]
}
```

### IAM Policy

#### KMS Policy

1. Create a policy that can access the KMS.
   - Service: KMS
   - Allow
     - `Decrypt`
     - `Encrypt`
     - `DescribeKey`
   - Resource: Key's ARN
     - ARN: `arn:aws:kms:ap-northeast-2:xxxxxxxxxxxx:key/xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx`
   - Name: `VaultKMSPolicy`
   - Description: `Use Vault KMS`

```json
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "kms:Decrypt",
                "kms:Encrypt",
                "kms:DescribeKey"
            ],
            "Resource": "arn:aws:kms:ap-northeast-2:xxxxxxxxxxxx:key/xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx"
        }
    ]
}
```

#### Vault EC2 Instance Policy

- Name: `VaultEC2IAMPolicy`
- Description: `For Vault AWS IAM auth method`

```json
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "VisualEditor0",
            "Effect": "Allow",
            "Action": [
                "iam:GetRole",
                "ec2:DescribeInstances",
                "iam:GetInstanceProfile",
                "iam:ListGroupsForUser",
                "iam:GetUser",
                "iam:GetGroup"
            ],
            "Resource": "*"
        },
        {
            "Sid": "VisualEditor1",
            "Effect": "Allow",
            "Action": [
                "iam:DeleteAccessKey",
                "iam:GetAccessKeyLastUsed",
                "iam:UpdateAccessKey",
                "iam:GetUser",
                "iam:CreateAccessKey",
                "iam:ListAccessKeys"
            ],
            "Resource": "arn:aws:iam::*:user/${aws:username}"
        },
        {
            "Sid": "VisualEditor2",
            "Effect": "Allow",
            "Action": "sts:AssumeRole",
            "Resource": "arn:aws:iam::xxxxxxxxxxx:role/vault-ec2"
        }
    ]
}
```

### IAM Role

- Trusted entity: `AWS Services`
- For: `EC2`
- Policiy:
   - `VaultKMSPolicy`
   - `VaultEC2IAMPolicy`
- Role name: `vault-ec2`
- Description: `Allows EC2 instances to call KMS and IAM`

---

## Terraform configurations: variables.tf

### AWS Credential Profile

```json
variable "profile" {
  default     = "default"
  description = "$HOME/.aws/credentials: [default]"
}
```

### Key pair

#### Vault

- `key_name`: `vault`
- `private_key`: `~/.ssh/vault.pem`

```json
variable "key_name" {
  default     = "vault"
  description = "EC2 Key Pair Name"
}

variable "private_key" {
  default     = "~/.ssh/vault.pem"
  description = "EC2 Private Key"
}
```

#### Bastion

```json
variable "bastion_private_key" {
  default     = "~/.ssh/bastion.pem"
  description = "Bastion Private Key"
}
```

---

## Terraform Provision

```bash
cd production/terraform
```

```bash
production/terrafrom
├── ansible
│   ├── ansible.cfg # ansible configurations
│   ├── files
│   │   ├── vault-x.hcl.tpl # in template.sh
│   │   └── vault.service # vault cli
│   ├── playbook.yml # ansbile deployment configurations
│   ├── ssh
│   │   └── config.template # SSH
│   └── template.sh # Start ansible
├── ansible.tf
├── main.tf
├── outputs.tf
└── variables.tf
```

### SSH Key

```bash
ssh-add ~/.ssh/bastion.pem
ssh-add ~/.ssh/vault.pem
ssh-add -L
```

### Terrafrom Init

```bash
terraform init
```

```bash
Terraform has created a lock file .terraform.lock.hcl
Terraform has been successfully initialized!
```

### Formatting

```bash
terraform fmt
```

### Validate

```bash
terraform validate
Success! The configuration is valid.
```

### Check deployment informations

```bash
terraform plan
```

### Terraform provision

```bash
terraform apply
```

### Ansible Playbook

You can run Ansible again with this command.:

```bash
cd ansible
ansible-playbook -i inventory playbook.yml
```

### Terraform remove

```bash
terraform destroy
```
