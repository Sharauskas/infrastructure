provider "aws" {
  region  = var.aws_region
  profile = var.profile
}

### Backend for S3 and DynamoDB ###
terraform {
  backend "s3" {
    bucket         = "cg-terraform-state-prod"
    key            = "terraform.tfstate"
    region         = "eu-central-1"
    dynamodb_table = "cg-terraform-lock-prod"
    profile        = "coingate"
    encrypt        = true
  }
}

module "ECR" {
  source       = "../../modules/ECR"
  project      = var.project
  group        = var.group
  env          = var.env
  scan_on_push = var.scan_on_push
  image_count  = var.image_count
}

module "VPC" {
  source  = "../../modules/VPC"
  project = var.project
  group   = var.group
  env     = var.env
  azs     = var.azs
  vpc_cidr = "10.2.0.0/16"
  public_subnets = ["10.2.1.0/24", "10.2.2.0/24"]
}

module "ECS" {
  source = "../../modules/ECS"

  project               = var.project
  group                 = var.group
  env                   = var.env
  aws_region            = var.aws_region
  subnets               = module.VPC.public_subnets_id
  vpc_id                = module.VPC.vpc
  ecr_app_url           = module.ECR.ecr_app_url
}

module "S3" {
  source = "../../modules/S3"

  project = var.project
  group   = var.group
  env     = var.env
}

module "SecretsManager" {
  source = "../../modules/SecretManager"

  project = var.project
  group   = var.group
  env     = var.env
}



