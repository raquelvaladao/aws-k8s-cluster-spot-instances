variable "vpc_name" {
}
variable "vpc_range" {}
variable "public_subnets" {}
variable "private_subnets" {}

variable "instance_keypair" {}
variable "cluster_name" {}

# bastion
variable "bastion_username" {}
variable "key_full_path" {}

variable "kube_port_api" {}