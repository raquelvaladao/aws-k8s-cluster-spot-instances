resource "aws_autoscaling_group" "asg_workers" {
  name                = "${var.cluster_name}-workers"
  force_delete        = true
  vpc_zone_identifier = aws_subnet.private_subnets[*].id
  max_size            = 2
  min_size            = 2
  target_group_arns   = [aws_lb_target_group.target_group_alb_external.arn]
  depends_on          = [aws_lb.alb_external]
  health_check_type   = "EC2"


  lifecycle {
    ignore_changes = [load_balancers, target_group_arns]
  }

  mixed_instances_policy {
    launch_template {
      launch_template_specification {
        launch_template_id = aws_launch_template.launch_template_worker.id
      }
      override {
        instance_type = "r3.large"
      }
      override {
        instance_type = "t2.large"
      }
      override {
        instance_type = "m4.large"
      }
    }

    instances_distribution {
      on_demand_base_capacity                  = 0
      on_demand_percentage_above_base_capacity = 0
      spot_allocation_strategy                 = "lowest-price"
      spot_max_price                           = 0.15
    }
  }

  tag {
    key                 = "Name"
    value               = "${var.cluster_name}-worker"
    propagate_at_launch = true
  }
}


resource "aws_autoscaling_group" "asg_master" {
  name                = "${var.cluster_name}-master"
  force_delete        = true
  vpc_zone_identifier = aws_subnet.private_subnets[*].id
  max_size            = 1
  min_size            = 1

  lifecycle {
    ignore_changes = [load_balancers, target_group_arns]
  }

  mixed_instances_policy {
    launch_template {
      launch_template_specification {
        launch_template_id = aws_launch_template.launch_template_master.id
      }
      override {
        instance_type = "r3.large"
      }
      override {
        instance_type = "t2.large"
      }
      override {
        instance_type = "m4.large"
      }
    }

    instances_distribution {
      on_demand_base_capacity                  = 0
      on_demand_percentage_above_base_capacity = 0
      spot_allocation_strategy                 = "lowest-price"
      spot_max_price                           = 0.15
    }
  }

  tag {
    key                 = "Name"
    value               = "${var.cluster_name}-master"
    propagate_at_launch = true
  }
}


data "aws_instances" "workers" {
  instance_tags = {
    Name = "${var.cluster_name}"
  }

  depends_on = [aws_autoscaling_group.asg_workers]
}


resource "aws_launch_template" "launch_template_worker" {
  name                   = "worker-lt"
  description            = "worker launch template"
  image_id               = data.aws_ami.linux.id
  key_name               = try(var.instance_keypair, null)
  vpc_security_group_ids = [aws_security_group.ec2_sg.id]

  lifecycle {
    create_before_destroy = true
  }

  tags = {
    "Name" = "${var.cluster_name}-worker"
  }
  user_data = base64encode(data.template_file.httpd_template.rendered)
}

resource "aws_launch_template" "launch_template_master" {
  name                   = "master-lt"
  description            = "master launch template"
  image_id               = data.aws_ami.linux.id
  key_name               = try(var.instance_keypair, null)
  vpc_security_group_ids = [aws_security_group.ec2_sg.id]

  lifecycle {
    create_before_destroy = true
  }

  tags = {
    "Name" = "${var.cluster_name}-master"
  }
  user_data = base64encode(data.template_file.httpd_template.rendered)

}

data "aws_ami" "linux" {
  most_recent = true

  owners = ["amazon"]

  filter {
    name   = "owner-alias"
    values = ["amazon"]
  }

  filter {
    name   = "architecture"
    values = ["x86_64"]
  }

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm*"]
  }
}

data "template_file" "httpd_template" {
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