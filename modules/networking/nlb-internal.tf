resource "aws_lb" "nlb_internal" {
  name               = "nlb-internal-${var.cluster_name}"
  internal           = true
  load_balancer_type = "network"
  subnets            = aws_subnet.private_subnets[*].id
}

resource "aws_lb_target_group" "target_group_nlb_internal" {
  name       = "target-group-nlb-internal"
  port       = var.kube_port_api
  protocol   = "TCP"
  vpc_id     = aws_vpc.k8s-vpc.id
  depends_on = [aws_vpc.k8s-vpc]

  health_check {
    interval = 70
    protocol = "TCP"
  }
}

resource "aws_lb_listener" "nlb_listener" {
  load_balancer_arn = aws_lb.nlb_internal.arn

  port     = var.kube_port_api
  protocol = "TCP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.target_group_nlb_internal.arn
  }
}

resource "aws_autoscaling_attachment" "nlb_target_attachment" {
  autoscaling_group_name = aws_autoscaling_group.asg_master.name
  lb_target_group_arn    = aws_lb_target_group.target_group_nlb_internal.arn

  depends_on = [
    aws_autoscaling_group.asg_master,
    aws_lb_target_group.target_group_nlb_internal
  ]
}