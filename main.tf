# Configure the AWS Provider
provider "aws" {
  region     = "us-east-1"
  access_key = "test"
  secret_key = "test"

  skip_credentials_validation = true
  skip_metadata_api_check     = true
  skip_requesting_account_id  = true
  skip_region_validation      = true

  endpoints {
    s3  = "http://floci:4566"
    ec2 = "http://floci:4566"
    iam = "http://floci:4566"
    eks = "http://floci:4566"
  }
  s3_use_path_style = true
}

module "networking" {
  source = "./modules/environment/networking"

  providers = {
    aws = aws
  }
  cluster_name = "${var.env_name}-cluster"

}

module "cluster" {
  source = "./modules/environment/cluster"

  providers = {
    aws = aws
  }
  cluster_name = "${var.env_name}-cluster"
  cluster_vpc  = module.networking.vpc_id
  depends_on = [module.networking.cluster_vpc,
    module.networking.az1,
    module.networking.az2,
  module.networking.az3]

}

module "s3" {
  source = "./modules/environment/s3"

  providers = {
    aws = aws
  }
  env_name     = var.env_name
  owner        = var.owner
  applications = var.applications
}

module "pods" {
  source = "./modules/environment/pods"

  providers = {
    aws = aws
  }
  cluster_name = "${var.env_name}-cluster"
  cluster_id   = module.cluster.cluster_id
  applications = var.applications

}

data "aws_availability_zones" "available" {
  state = "available"
}

output "azs" {
  value = data.aws_availability_zones.available.names
}

data "aws_subnets" "example" {

}

output "subnet_ids" {
  value = data.aws_subnets.example.ids
}
