variable "environment" {
  type        = string
  description = "Used to specify a prefix for a name: dev, test, prod"
}

variable "project_name" {
  type        = string
  description = "Determine the project name"
}

variable "resource_group" {
  type        = string
  description = "Terraform State Resource Group"
}

variable "location" {
  type        = string
  default     = "West Europe"
  description = "The geographical localtion of the resource in the data center"
}

variable "local_ip" {
  type        = list(string)
  description = "My local IP so terraform has access to resources behind a firewall"
}

variable "owner_email" {
  type        = string
  sensitive   = true
  description = "The person that should be emailed when costs exceed a threshold, see main.tf"
}

variable "storage_account" {
  type        = string
  sensitive   = true
  description = "Storage account for terraform state"
}

variable "storage_container" {
  type        = string
  sensitive   = false
  description = "Terraform state container"
}