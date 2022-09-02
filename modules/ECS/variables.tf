variable "project" {}
variable "group" {}
variable "env" {}
variable "aws_region" {}
variable "subnets" {}
variable "vpc_id" {}
variable "ecr_app_url" {}

variable "ecs_task_execution_role_name" {
  description = "ECS task execution role name"
  default     = "myEcsTaskExecutionRole"
}

variable "app_port" {
  default = 5000
}

variable "fargate_cpu" {
  default = 256
}

variable "fargate_memory" {
  default = 512
}