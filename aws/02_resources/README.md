# Internal LoadBalancer

Internal Domain: `vault.example.private`

- Kubernetes needs to access the vault in another subnet. 
- An internal load balancer and internal domain are required.

## Target Group

The target group sends traffic to a specific port on EC2.

- Type: Instances
- Name: `Vault`
- TCP: `8200`
- VPC: VIP VPC (`vpc-xxxxxxxxxxxxxxxxx`)
- Health checks
   - HTTP: `/v1/sys/health`
   - Override: `8200`


## Network Load Balancer

A network load balancer can configure only one subnet. (Application LB requires at least 2 subnets.)

- Name: `Vault`
- Scheme: `Internal`
- VPC: `vpc-xxxxxxxxxxxxxxxxx`
- Subnet: `Private Vault Subnet A` (`subnet-xxxxxxxxxxxxxxxxx`)
- Listner Ports: `TCP` `8200`
   - Forward to: `Vault`

## Route 53

1. Create a hosted zone
   - `example.private`
   - Type: Private hosted zone
   - VPC: `vpc-xxxxxxxxxxxxxxxxx`
1. Add a record
   - Name: `vault`
   - Type: A
   - Alias:
     - Network Load Balancer
     - Seoul
     - `Vault`

Now in `VPC`, `vault.example.private:8200` points to port 8200 on EC2 where the vault is located.
