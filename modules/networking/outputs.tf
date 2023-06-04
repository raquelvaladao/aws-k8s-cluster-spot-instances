output "vpc_id" {
  value = aws_vpc.k8s-vpc.id
}

output "bastion_ip" {
  value = aws_instance.bastion.public_ip
}