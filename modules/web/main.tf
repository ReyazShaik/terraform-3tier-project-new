resource "aws_launch_template" "web" {
  name_prefix            = "web-"
  image_id               = var.ami_id
  instance_type          = var.instance_type
  vpc_security_group_ids = var.sg_ids
  user_data = base64encode(<<-EOF
    #!/bin/bash
    yum install -y httpd
    cat > /etc/httpd/conf.d/app-proxy.conf <<CONF
    ProxyPass /api http://${var.app_alb_dns}/
    ProxyPassReverse /api http://${var.app_alb_dns}/
    CONF
    systemctl enable --now httpd
    EOF
  )
}

resource "aws_autoscaling_group" "web" {
  desired_capacity    = var.desired_capacity
  min_size            = var.min_size
  max_size            = var.max_size
  vpc_zone_identifier = var.subnets
  health_check_type   = "ELB"
  launch_template {
    id      = aws_launch_template.web.id
    version = "$Latest"
  }
  tag {
    key                 = "Name"
    value               = "web"
    propagate_at_launch = true
  }
}

resource "aws_lb" "web" {
  internal           = false
  load_balancer_type = "application"
  subnets            = var.alb_subnets
  security_groups    = [var.alb_sg_id]
}

resource "aws_lb_target_group" "web" {
  port     = 80
  protocol = "HTTP"
  vpc_id   = var.vpc_id
  health_check {
    path = "/"
  }
}

resource "aws_lb_listener" "web" {
  load_balancer_arn = aws_lb.web.arn
  port              = "80"
  protocol          = "HTTP"
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.web.arn
  }
}

resource "aws_autoscaling_attachment" "web_tg" {
  autoscaling_group_name = aws_autoscaling_group.web.name
  lb_target_group_arn    = aws_lb_target_group.web.arn
}

output "alb_dns" {
  value = aws_lb.web.dns_name
}
