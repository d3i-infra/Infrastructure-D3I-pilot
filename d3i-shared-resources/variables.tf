variable "project_name" {
  type        = string
  description = "Determine the project name"
}

variable "location" {
  type        = string
  default     = "West Europe"
  description = "The geographical localtion of the resource in the data center"
}

variable "owner_email" {
  type        = string
  sensitive   = true
  description = "The person that should be emailed when costs exceed a threshold, see main.tf"
}

variable "imagename_privacy_support_server" {
  type        = string
  description = "Image name of the server that servers the privacy and support page"
}

variable "imagetag_privacy_support_server" {
  type        = string
  description = "Image tag of the server that serves the privacy and support page"
}
