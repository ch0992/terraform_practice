resource "aws_security_group" "alb-sg" {
  name        = "alb-sg"
  description = "Allow alb inbound traffic"
  vpc_id      = aws_vpc.vpc-10-0-0-0.id

  ingress {
    description      = "ALB from VPC"
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
  }

  tags = {
    Name = "alb-sg"
  }
}

resource "aws_lb" "tf-alb" {
  name               = "tf-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb-sg.id]
  subnets            = [aws_subnet.sub-pub1-10-0-1-0.id, aws_subnet.sub-pub2-10-0-2-0.id]
  enable_deletion_protection = false
  tags = {
    Name = "tf-alb"
  }
}

resource "aws_lb_target_group" "alb-tg" {
  name     = "alb-tg"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.vpc-10-0-0-0.id

    health_check {
      enabled = true
      healthy_threshold = 3
      interval = 5
      matcher = "200"
      path = "/"
      port = "traffic-port"
      protocol = "HTTP"
      timeout = 2
      unhealthy_threshold = 2
    }
}

resource "aws_lb_listener" "alb-ln" {
  load_balancer_arn = aws_lb.tf-alb.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.alb-tg.arn
  }
}

resource "aws_lb_target_group_attachment" "foreach" {
  for_each = toset(data.aws_instances.test.ids)
  target_group_arn = aws_lb_target_group.alb-tg.arn
  target_id = each.key
  port = 80
}

data "aws_instances" "test" {
  filter{
    name = "tag:Name"
    values = ["web-*"]
  }
}

output "name" {
  value = toset(data.aws_instances.test.ids)
}

output "alb_dns_name" {
  value = aws_lb.tf-alb.dns_name
}