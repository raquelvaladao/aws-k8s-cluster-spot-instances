resource "aws_lb" "alb_external" {
  name               = "alb-${var.cluster_name}"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb_sg.id]
  subnets            = aws_subnet.public_subnets[*].id
}

resource "aws_lb_target_group" "target_group_alb_external" {
  name       = "target-group-alb-external"
  port       = 80
  protocol   = "HTTP"
  vpc_id     = aws_vpc.k8s-vpc.id
  depends_on = [aws_vpc.k8s-vpc]

  health_check {
    interval            = 70
    path                = "/index.html"
    port                = 80
    healthy_threshold   = 2
    unhealthy_threshold = 5
    timeout             = 60
    protocol            = "HTTP"
    matcher             = "200,202"
  }
}

resource "aws_lb_listener" "alb_listener" {
  load_balancer_arn = aws_lb.alb_external.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.target_group_alb_external.arn
  }
}