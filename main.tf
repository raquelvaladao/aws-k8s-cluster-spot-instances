terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "4.67.0"
    }
  }
  backend "s3" {}
}

provider "aws" {
  access_key = var.access_key
  secret_key = var.secret_key
  region     = var.region
}

module "networking" {
  source = "./modules/networking"

  vpc_name         = var.vpc_name
  vpc_range        = var.vpc_range
  public_subnets   = var.public_subnets
  private_subnets  = var.private_subnets
  instance_keypair = var.instance_keypair
  cluster_name     = var.cluster_name
  key_full_path    = var.key_full_path
  bastion_username = var.bastion_username
  kube_port_api    = var.kube_port_api
}

module "bootstraping" {
  source = "./modules/bootstraping"

  worker_instances_private_ips = module.networking.worker_instances_private_ips
  master_instances_private_ips = module.networking.master_instances_private_ips
  bastion_ip                   = module.networking.bastion_ip
}