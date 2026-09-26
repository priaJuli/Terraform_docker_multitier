variable "postgres_admin_password" {
  description = "The master password for the PostgreSQL container."
  type        = string
  sensitive   = true
  validation {
    condition     = length(var.postgres_admin_password) >= 16
    error_message = "Admin password must be at least 16 characters."
  }
}

variable "app_db_password" {
  description = "Password for the new db_A user."
  type        = string
  sensitive   = true
  validation {
    condition     = length(var.app_db_password) >= 16
    error_message = "App password must be at least 16 characters."
  }
}

variable "redis_user" {
  description = "The Redis ACL username."
  type        = string
  default     = "app_redis_user"
  validation {
    condition     = can(regex("^[a-zA-Z0-9_]+$", var.redis_user))
    error_message = "Redis user must be alphanumeric."
  }
}

variable "redis_password" {
  description = "Password for the Redis user."
  type        = string
  sensitive   = true
  validation {
    condition     = length(var.redis_password) >= 16
    error_message = "Redis password must be at least 16 characters."
  }
}

variable "postgres_host" {
  description = "The host IP Terraform uses to connect to Postgres. Use 'localhost' if running TF on the VPS, or the VPS public IP if running TF locally."
  type        = string
  default     = "localhost"
  validation {
    condition     = can(regex("^(localhost|[0-9]{1,3}(\\.[0-9]{1,3}){3})$", var.postgres_host))
    error_message = "Must be 'localhost' or a valid IPv4 address."
  }
}