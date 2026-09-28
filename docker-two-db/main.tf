# 1. Remote Docker Network
resource "docker_network" "app_network" {
  name = "remote-app-network"
}

# 2. Remote PostgreSQL Container
resource "docker_container" "postgres" {
  name  = "remote-postgres"
  image = "postgres:15-alpine"
  restart = "always"

  networks_advanced {
    name = docker_network.app_network.name
  }

  # Strict: Expose to the VPS public interface. 
  # Your VPS firewall MUST restrict this to your home IP.
  ports {
    internal = 5432
    external = 5432
    ip       = "0.0.0.0"
  }

  env = [
    "POSTGRES_PASSWORD=${var.db_password}",
    "POSTGRES_DB=db_A"
  ]
}

# 3. Remote Redis Container
resource "docker_container" "redis" {
  name  = "remote-redis"
  image = "redis:7-alpine"
  restart = "always"

  networks_advanced {
    name = docker_network.app_network.name
  }

  ports {
    internal = 6379
    external = 6379
    ip       = "0.0.0.0"
  }
}