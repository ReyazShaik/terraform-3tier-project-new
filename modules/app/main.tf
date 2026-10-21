resource "aws_launch_template" "app" {
  name_prefix            = "app-"
  image_id               = var.ami_id
  instance_type          = var.instance_type
  vpc_security_group_ids = var.sg_ids
  user_data = base64encode(<<-EOF
    #!/bin/bash
    yum install -y python3
    mkdir -p /srv/app && echo ok > /srv/app/index.html
    cd /srv/app && nohup python3 -m http.server 8080 &
    EOF
  )
}

resource "aws_autoscaling_group" "app" {
  desired_capacity    = var.desired_capacity
  min_size            = var.min_size
  max_size            = var.max_size
  vpc_zone_identifier = var.subnets
  target_group_arns   = [aws_lb_target_group.app.arn]
  health_check_type   = "ELB"
  launch_template {
    id      = aws_launch_template.app.id
    version = "$Latest"
  }
  tag {
    key                 = "Name"
    value               = "app"
    propagate_at_launch = true
  }
}

resource "aws_lb" "app" {
  name_prefix        = "app-"
  internal           = true
  load_balancer_type = "application"
  subnets            = var.alb_subnets
  security_groups    = [var.alb_sg_id]
}

resource "aws_lb_target_group" "app" {
  port     = 8080
  protocol = "HTTP"
  vpc_id   = var.vpc_id
  health_check {
    path = "/"
  }
}

resource "aws_lb_listener" "app" {
  load_balancer_arn = aws_lb.app.arn
  port              = "80"
  protocol          = "HTTP"
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.app.arn
  }
}

output "alb_dns" {
  value = aws_lb.app.dns_name
}
