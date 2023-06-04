variable "access_key" {
  type = string
}
variable "secret_key" {
  type = string
}
variable "region" {
  default = "sa-east-1"
  type    = string
}
variable "instance_keypair" {
  description = "Key pair name of the fleet instances"
  type        = string
}
variable "cluster_name" {
  default = "k8s-cluster"
  type    = string
}

#networking
variable "vpc_name" {
  default = "k8s-vpc"
  type    = string
}
variable "vpc_range" {
  default = "10.240.0.0/23"
  type    = string
}
variable "public_subnets" {
  type = list(object({
    az    = string
    range = string
  }))
  default = [
    {
      "az" : "sa-east-1a",
      "range" : "10.240.0.0/27"
    },
    {
      "az" : "sa-east-1b",
      "range" : "10.240.0.64/27"
    },
    {
      "az" : "sa-east-1c",
      "range" : "10.240.0.128/27"
    },
  ]
}
variable "private_subnets" {
  type = list(object({
    az    = string
    range = string
  }))
  default = [
    {
      "az" : "sa-east-1a",
      "range" : "10.240.0.32/27"
    },
    {
      "az" : "sa-east-1b",
      "range" : "10.240.0.96/27"
    },
    {
      "az" : "sa-east-1c",
      "range" : "10.240.0.160/27"
    },
  ]
}

variable "bastion_username" {
  default = "ec2-user"
  type    = string
}
variable "key_full_path" {
  default = "/c/user/user_example/downloads/instance_keypair.pem"
  type    = string
}
variable "kube_port_api" {
  default = 6443
  type    = number
}