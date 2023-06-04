resource "aws_instance" "bastion" {
  ami           = data.aws_ami.linux.id
  instance_type = "t2.micro"
  key_name      = var.instance_keypair

  subnet_id              = aws_subnet.public_subnets[0].id # sa-east-1a
  vpc_security_group_ids = [aws_security_group.ec2_sg.id]

  tags = {
    Name = "bastion-host"
  }
  user_data = base64encode(data.template_file.file.rendered)
}

data "template_file" "file" {
  template = <<EOF
  #!/bin/bash
  yum update -y
  amazon-linux-extras install epel -y
  yum -y install httpd jq  
  echo "TEST! 
  My instance-id is $(curl -s http://169.254.169.254/latest/meta-data/instance-id)
  My instance type is $(curl -s http://169.254.169.254/latest/meta-data/instance-type)
  I'm on Availability Zone $(curl -s http://169.254.169.254/latest/meta-data/placement/availability-zone)" > /var/www/html/index.html
  service httpd start
  EOF
}