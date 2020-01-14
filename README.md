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
Create `config.tfvars` file by using the `config.tfvars.example` template.
Update it with your AWS account details.

Use `make` to manage the infrastructure.

### Troubleshooting
In some cases, you might need to create and destroy the stacks individually
and then just go to a directory and run the terraform from there, eg.:
`terraform init && terraform apply -var-file=../../config.tfvars`

