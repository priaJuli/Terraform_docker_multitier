variable "vps_ip" {
  description = "The public IP address of your existing Hostinger VPS."
  type        = string
  
  validation {
    condition     = can(regex("^[0-9]{1,3}(\\.[0-9]{1,3}){3}$", var.vps_ip))
    error_message = "Must be a valid IPv4 address."
  }
}

variable "ssh_user" {
  description = "The SSH user to connect to the VPS (usually 'root' or a specific sudo user)."
  type        = string
  default     = "root"
}

variable "db_password" {
  description = "Password for the PostgreSQL database."
  type        = string
  sensitive   = true
}