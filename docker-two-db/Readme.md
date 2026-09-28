# Simple terraform to create docker container. 

This folder only contains, for code terraform to create two docker container postgresql and redis.

The postgresql is simple configured with root password that set in file terraform.tfvars.

# Follow this to run the terraform code.

```bash

terraform init

terraform plan -out=tfplan

terraform apply tfplan

```