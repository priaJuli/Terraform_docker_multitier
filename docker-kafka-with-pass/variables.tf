variable "vps_public_ip" {
  description = "The public IP of the VPS (Crucial for Kafka advertised listeners)"
  type        = string
}

variable "ssh_user" {
  description = "SSH user for the VPS"
  type        = string
  default     = "root"
}

variable "ssh_private_key" {
  description = "Path to SSH private key or the key content"
  type        = string
  sensitive   = true
}

variable "kafka_admin_password" {
  description = "Password for the Kafka admin user"
  type        = string
  default     = "admin_secure_pass"
  sensitive   = true
}

variable "kafka_user_password" {
  description = "Password for the standard Kafka user"
  type        = string
  default     = "user_secure_pass"
  sensitive   = true
}