terraform {
  required_version = ">= 1.5.0"
  
  required_providers {
    docker = {
      source  = "kreuzwerker/docker"
      version = "~> 3.0.2"
    }
    postgresql = {
      source  = "cyrilgdn/postgresql"
      version = "~> 1.22.0"
    }
    time = {
      source  = "hashicorp/time"
      version = "~> 0.11.1"
    }
  }

  backend "local" {
    path = "state/terraform.tfstate"
  }
}

provider "docker" {}

# This provider connects to the running Postgres container to manage DB/Users
provider "postgresql" {
  host            = var.postgres_host
  port            = 5432
  database        = "postgres" # Connect to default DB to create new ones
  username        = "postgres"
  password        = var.postgres_admin_password
  sslmode         = "disable" # Local/VPS internal network, disable for simplicity
  connect_timeout = 15
}