variable "group" {}
variable "project" {}
variable "env" {}
variable "vpc_cidr" {
  type        = string
  description = "The CIDR block for the VPC"
}
variable "azs" {}
variable "public_subnets" {
  type        = list(string)
  description = "List of public subnets"
}