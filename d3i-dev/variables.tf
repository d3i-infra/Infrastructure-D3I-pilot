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
  type        = list(string)
  description = "My local IP so terraform has access to resources behind a firewall"
}

variable "postgres_username" {
  type        = string
  sensitive   = true
  description = "Username for postgres database"
}

variable "data_encryption_public_rsa_key" {
  type        = string
  sensitive   = true
  description = "Public RSA key that is used to encrypt data donated by participants"
}

variable "owner_email" {
  type        = string
  sensitive   = true
  description = "The person that should be emailed when costs exceed a threshold, see main.tf"
}

variable "database_name" {
  type        = string
  description = "Postgresql Database Name"
}

variable "app_listening_port" {
  type        = number
  description = "Port we communicate to azure to connect to"
}

variable "dockerimagename" {
  type        = string
  description = "Docker image name, for example 'next'"
}

variable "dockerimagetag" {
  type        = string
  description = "Which version to use like 'latest' or specific release"
}

variable "costmonitor_startdate" {
  type        = string
  description = "Required for budget monitoring (start date)"
}

variable "costmonitor_enddate" {
  type        = string
  description = "Required for budget monitoring (end date) max one year"
}

variable "project_name_automation_account" {
  type        = string
  description = "The project name of the project that the automation account is in"
}
