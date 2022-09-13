variable "environment" {
  type        = string
  default     = ""
  description = "Used to specify a prefix for a name: dev, test, prod"
}

variable "project_name" {
  type        = string
  description = "Determine the project name"
}

variable "location" {
  type        = string
  default     = "West Europe"
  description = "The geographical localtion of the resource in the data center"
}

variable "local_ip" {
  type        = string
  sensitive   = true
  description = "My local IP so terraform has access to resources behind a firewall"
}

variable "postgres_username" {
  type        = string
  sensitive   = true
  description = "Username for postgres database"
}

variable "postgres_password" {
  type        = string
  sensitive   = true
  description = "Password for postgres database"
}

variable "data_encryption_public_rsa_key" {
  type        = string
  sensitive   = true
  description = "Public RSA key that is used to encrypt data donated by participants"
}


