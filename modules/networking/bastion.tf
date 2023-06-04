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
  sudo yum -y install jq gcc openssl-devel
  sudo yum groupinstall "Development tools" -y
  cd
  sudo wget http://ftp.gnu.org/gnu/wget/wget-1.16.tar.gz
  sudo tar -xzf wget-1.16.tar.gz
  cd wget-1.16
  sudo ./configure --with-ssl=openssl
  sudo make && sudo make install
  cd
  sudo curl -s -L -o /bin/cfssl https://pkg.cfssl.org/R1.2/cfssl_linux-amd64
  sudo curl -s -L -o /bin/cfssljson https://pkg.cfssl.org/R1.2/cfssljson_linux-amd64
  sudo curl -s -L -o /bin/cfssl-certinfo https://pkg.cfssl.org/R1.2/cfssl-certinfo_linux-amd64
  sudo chmod +x /bin/cfssl*
  sudo wget https://storage.googleapis.com/kubernetes-release/release/v1.21.0/bin/linux/amd64/kubectl
  sudo chmod +x kubectl
  sudo mv kubectl /usr/local/bin/
  EOF
}