variable "environment" {
  type        = string
  default     = ""
  description = "Used to specify a prefix for a name: dev, test, prod"
}

variable "project_name" {
  type        = string
  description = "Name of the project name"
}

variable "location" {
  type        = string
  default     = "West Europe"
  description = "The geographical localtion of the resource in the data center"
}

variable "local_ip" {
  type        = list(string)
  description = "The IP of the terraform user, so terraform has access to resources behind a firewall"
}

variable "postgres_username" {
  type        = string
  sensitive   = true
  description = "Username for postgres database"
}

variable "data_encryption_public_rsa_key" {
  type        = string
  sensitive   = true
  default     = "test"
  description = "This is not used ATM. is here for reference"
}

variable "owner_email" {
  type        = string
  sensitive   = true
  description = "Email of the owner. Also the person that should be emailed when costs exceed a threshold, see main.tf"
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
  description = "Docker image name"
}

variable "dockerimagetag" {
  type        = string
  description = "Image version. For example: 'latest' or 1.1.1"
}

variable "costmonitor_startdate" {
  type        = string
  description = "Start date for cost monitoring: 2023-02-01T00:00:00Z should be the first day of the current month"
}

variable "costmonitor_enddate" {
  type        = string
  description = "End date for cost monitoring: 2023-02-01T00:00:00Z should be the first day of the month"
}

variable "project_name_automation_account" {
  type        = string
  description = "The project name of the project that the automation account is in: see shared resourcees"
}

variable "sas_token_startdate" {
  type        = string
  description = "Start date of the SAS token. The SAS token is used by the app to authenticate with the storage account. Example: 2023-01-29"
}

variable "sas_token_enddate" {
  type        = string
  description = "Expiry date of the SAS token. The SAS token is used by the app to authenticate with the storage account. Example: 2023-01-29"
}
