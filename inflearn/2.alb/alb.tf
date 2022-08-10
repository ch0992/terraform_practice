provider "aws" {
  region = "ap-northeast-2"
}

variable "vpc_id" {
  default = "vpc-00d4da8109a0cf540"
}
variable "subnet_id" {
  default = ["subnet-09b3892ccd00c5c0c","subnet-0b4bb5485ac597404"]
}

# data "aws_vpc" "foo" {}
data "aws_vpc" "bar" {}


### subnet_ids 사용하여 출력 - Deprecated
# data "aws_subnet_ids" "example" {
# #  vpc_id = var.vpc_id
#   vpc_id = data.aws_vpc.foo.id
# }

# data "aws_subnet" "example" {
#   for_each = data.aws_subnet_ids.example.ids
#   id       = each.value
# }

# output "vpc_id" {
#   value = data.aws_vpc.foo.id
# }


#### subnets 사용하여 정의 및 출력

data "aws_subnets" "example2" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.bar.id]
  }
}
####
data "aws_subnet" "example2" {
  for_each = toset(data.aws_subnets.example2.ids)
  id       = each.value
}

output "vpc_id" {
  value = data.aws_vpc.bar.id
}

output "subnet_cidr_blocks" {
  value = [for s in data.aws_subnet.example2 : s.cidr_block]
}

output "alb_dns_name" {
  value = aws_lb.test.dns_name
}

resource "aws_security_group" "allow_alb" {
  name        = "allow_alb"
  description = "Allow alb inbound traffic"
  vpc_id      = var.vpc_id

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
    Name = "allow_alb"
  }
}

resource "aws_lb" "test" {
  name               = "test-lb-tf"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.allow_alb.id]
  #subnets            = var.subnet_id
  subnets            = data.aws_subnets.example2.ids

  #alb 삭제안되도록 보호 false로 변경해야함
  enable_deletion_protection = false

  tags = {
    Name = "alb"
  }
}

resource "aws_lb_target_group" "ip-example" {
  name     = "tf-example-lb-tg"
  port     = 80
  protocol = "HTTP"
  target_type = "ip"
  vpc_id   = data.aws_vpc.bar.id

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

resource "aws_lb_listener" "front_end" {
  load_balancer_arn = aws_lb.test.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.ip-example.arn
  }
}

###### 단일 attachment 정의

# resource "aws_lb_target_group_attachment" "test-2a" {
#   target_group_arn = aws_lb_target_group.ip-example.arn
#   target_id        = data.aws_instances.test.private_ips[0]
#   port             = 80
# }

# resource "aws_lb_target_group_attachment" "test-2c" {
#   target_group_arn = aws_lb_target_group.ip-example.arn
#   target_id        = data.aws_instances.test.private_ips[1]
#   port             = 80
# }


#### for_each로 target id 정의

# resource "aws_lb_target_group_attachment" "test-2a" {
#   for_each = toset(data.aws_instances.test.private_ips)
#   target_group_arn = aws_lb_target_group.ip-example.arn
#   #target_id        = data.aws_instances.test.private_ips[1]
#   target_id = each.value
#   port             = 80
# }

#### count로 target id 정의
resource "aws_lb_target_group_attachment" "test-2a" {
  count = length(data.aws_instances.test.private_ips)
  target_group_arn = aws_lb_target_group.ip-example.arn
  #target_id        = data.aws_instances.test.private_ips[1]
  target_id = element(data.aws_instances.test.private_ips, count.index)
  port             = 80
}

data "aws_instances" "test" {
  instance_tags = {
    Name = "web-*"
  }
}
