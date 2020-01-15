# terraform-aws
Code template for multi-account, multi-region, multi-environment AWS
infrastructure

![diagram](https://github.com/nicholasgasior/terraform-aws/raw/master/diagram.jpg "diagram")

### Terraform
Version 0.12.18 has been used when writing the code.

### Structure
Code is split into three stacks: **network**, **base** and **apps**. These are
then split into environments like production, failover, staging and dev.

The network stack initialises all the necessary networking like VPC, subnets
etc. And VPC peerings between environments.

The base stack creates base environment resources required for running any
applications like security groups, roles, instance profiles etc. for EC2
instances, load balancers, RDS.

The apps stack creates application resources like load balancers, EC2
instances, DB instances, S3 buckets and so on.

### Running
#### Configuration
Create `config.tfvars` file by using the `config.tfvars.example` template.
Update it with your AWS account details.

Some configuration key explanation:

* aws_account_production - AWS account number for production
* aws_account_test - AWS account number for staging and dev environments
* aws_account_test_role_arn - ARN of role to be assumed to access test account
* route53_zone - ID of Route 53 zone of domain to use
* production_certificate - ARN of wildcard certificate for the domain in
  production region; it's used with load balancers
* failover_certificate - ARN of wildcard certificate for the domain in
  failover region; it's used with load balancers

#### Building
Use `make` to manage the infrastructure.

### Troubleshooting
In some cases, you might need to create and destroy the stacks individually
and then just go to a directory and run the terraform from there, eg.:
`terraform init && terraform apply -var-file=../../config.tfvars`

