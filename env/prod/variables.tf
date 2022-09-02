variable "profile" {
  default = "coingate"
}

variable "aws_region" {
  default = "eu-central-1"
}

variable "project" {
  default = "cg"
}

variable "group" {
  default = "testas"
}

variable "env" {
  default = "prod"
}

variable "azs" {
  type        = list(string)
  default     = ["eu-central-1a", "eu-central-1b"]
  description = "List of Availability Zones"
}


### ECR ###

variable "scan_on_push" {
  default = false
}

variable "image_count" {
  default = 3
}
