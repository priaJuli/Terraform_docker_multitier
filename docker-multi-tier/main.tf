# ==========================================
# 1. POSTGRESQL INFRASTRUCTURE
# ==========================================

resource "docker_volume" "postgres_data" {
  name = "vps-postgres-data"
}

resource "docker_container" "postgres" {
  name  = "vps-postgres"
  image = "postgres:15-alpine"
  restart = "always"

  # Expose to VPS network. Firewall MUST restrict this.
  ports {
    internal = 5432
    external = 5432
    ip       = "0.0.0.0" 
  }

  env = [
    "POSTGRES_PASSWORD=${var.postgres_admin_password}",
    "POSTGRES_HOST_AUTH_METHOD=scram-sha-256" # Strict auth method
  ]

  volumes {
    volume_name    = docker_volume.postgres_data.name
    container_path = "/var/lib/postgresql/data"
  }
}

# Strict Rule: Wait for Postgres to fully initialize before the provider attempts to connect.
# Without this, Terraform will fail on the first apply with "connection refused".
resource "time_sleep" "wait_for_postgres" {
  depends_on      = [docker_container.postgres]
  create_duration = "10s"
}

# ==========================================
# 2. POSTGRESQL LOGICAL RESOURCES (DB & USER)
# ==========================================

resource "postgresql_role" "app_user" {
  depends_on = [time_sleep.wait_for_postgres]
  
  name     = "db_a_user"
  login    = true
  password = var.app_db_password
}

resource "postgresql_database" "db_a" {
  depends_on = [postgresql_role.app_user]

  name              = "db_A"
  owner             = postgresql_role.app_user.name
  connection_limit  = 50 # Strict: Prevent connection exhaustion attacks
  
  # Strict: Revoke public access to this database
  revoke_connect_on_creation = true 
}

# Explicitly grant all privileges on the database to the specific user
resource "postgresql_grant" "db_a_all_privileges" {
  depends_on  = [postgresql_database.db_a]
  database    = postgresql_database.db_a.name
  role        = postgresql_role.app_user.name
  object_type = "database"
  privileges  = ["ALL"]
}

# ==========================================
# 3. REDIS INFRASTRUCTURE & ACL
# ==========================================

# Strict Rule: Generate Redis ACL file declaratively via Terraform.
# This disables the default user and creates a strict, password-protected user.
resource "local_file" "redis_acl" {
  content = <<-EOT
    # Disable the default user for strict security
    user default off
    
    # Create specific user with password, access to all keys (~*), and all commands (+@all)
    user ${var.redis_user} on >${var.redis_password} ~* &* +@all
  EOT
  filename = "${path.module}/redis-users.acl"
  file_permission = "0600" # Strict: Only owner can read/write
}

resource "docker_container" "redis" {
  name  = "vps-redis"
  image = "redis:7-alpine"
  restart = "always"

  # Expose to VPS network. Firewall MUST restrict this.
  ports {
    internal = 6379
    external = 6379
    ip       = "0.0.0.0"
  }

  # Mount the Terraform-generated ACL file into the container
  volumes {
    host_path      = local_file.redis_acl.filename
    container_path = "/usr/local/etc/redis/users.acl"
    read_only      = true
  }

  # Instruct Redis to use the ACL file
  command = ["redis-server", "--aclfile", "/usr/local/etc/redis/users.acl"]
}