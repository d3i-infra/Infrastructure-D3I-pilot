variable "project_name" {
  type        = string
  description = "Determine the project name"
}

variable "environment" {
  type        = string
  description = "Environment in which resources are being deployed (dev, test, prod)"
}

variable "location" {
  type        = string
  default     = "West Europe"
  description = "The geographical localtion of the resource in the data center"
}

variable "ssh_public_key_path" {
  type        = string
  description = "Path to a public key that can be used for passwordless ssh access"
}

variable "admin_username" {
  sensitive   = true
  type        = string
  description = "username of the admin account"
}

variable "admin_password" {
  sensitive   = true
  type        = string
  description = "password of the admin account"
}

variable "hostname" {
  type        = string
  description = "Hostname of the analysis server"
}
