# Packer: Vault AMI

- Private Subnet is not connected to the Internet, so it is difficult to install packages with Ansible.
  - To install a package in a private subnet, you need to upload the package to S3.
- Create and deploy an AMI with pre-installed packages.

## Install Packer

```bash
brew tap hashicorp/tap
brew install hashicorp/tap/packer
```

## Packer Configurations

[vault.pkr.hcl](./vault.pkr.hcl)

- AWS Profile
- AMI name: `vault`
- Instance Type: `t3a.medium`
- Region: Seoul `ap-northeast-2`
- OS: Ubuntu 20.04

## Packer Initialization

```bash
packer init .
```

## Prepare install

```bash
packer fmt .
packer validate .
```

## Build a image

```bash
packer build vault.pkr.hcl
```

## AMI ID

```bash
==> Builds finished. The artifacts of successful builds are:
--> amazon-ebs.ubuntu: AMIs were created:

ap-northeast-2: ami-xxxxxxxxxxxxxxxxx
```

Check the AMI in the AWS console.
