output "vpc_id" {
  value = aws_vpc.k8s-vpc.id
}

output "bastion_ip" {
  value = aws_instance.bastion.public_ip
}

output "worker_instances_private_ips" {
  value = data.aws_instances.workers_instances.private_ips
}

output "master_instances_private_ips" {
  value = data.aws_instances.master_instances.private_ips
}