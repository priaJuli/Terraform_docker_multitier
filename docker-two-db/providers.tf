terraform {
  required_version = ">= 1.5.0"
  required_providers {
    docker = {
      source  = "kreuzwerker/docker"
      version = "~> 3.0.2"
    }
  }
  backend "local" {
    path = "state/terraform.tfstate"
  }
}

# The Docker provider connects to the REMOTE VPS via SSH
provider "docker" {
  # Strict: Uses the SSH protocol. Terraform will use your local SSH agent 
  # to authenticate and tunnel into the VPS to talk to /var/run/docker.sock.
  host = "ssh://${var.ssh_user}@${var.vps_ip}"
}