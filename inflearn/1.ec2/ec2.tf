provider "aws" {
  region = "ap-northeast-2"
}

variable "vpc_id" {
  default = "vpc-00d4da8109a0cf540"
}

variable "subnet_id" {
  default = ["subnet-09b3892ccd00c5c0c","subnet-0b4bb5485ac597404"]
}

data "aws_ami" "amzn2" {
  most_recent = true

  filter {
    name   = "name"
    values = ["amzn2-ami-kernel-5.10-hvm-?.?.????????.?-x86_64-gp2"]
  }

//Amazon Linux 2 Kernel 5.10 AMI 2.0.20220719.0 x86_64 HVM gp2

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["amazon"] # Canonical
}

resource "aws_instance" "web-2a" {
  ami           = data.aws_ami.amzn2.id
  instance_type = "t2.micro"
  key_name = "tf-key-pair"
  vpc_security_group_ids = [aws_security_group.allow_web.id]
  availability_zone = "ap-northeast-2a"
  subnet_id = var.subnet_id[0]
  user_data = file("./init-script.sh")

  root_block_device {
    volume_size = 30
  }

  tags = {
    Name = "web-2a"
  }
}

resource "aws_instance" "web-2c" {
  ami           = data.aws_ami.amzn2.id
  instance_type = "t2.micro"
  key_name = "tf-key-pair"
  vpc_security_group_ids = [aws_security_group.allow_web.id]
  availability_zone = "ap-northeast-2c"
  subnet_id = var.subnet_id[1]
  user_data = file("./init-script.sh")

  root_block_device {
    volume_size = 30
  }

  tags = {
    Name = "web-2c"
  }
}



resource "aws_security_group" "allow_web" {
  name        = "allow_web"
  description = "Allow Web inbound traffic"
  vpc_id      = var.vpc_id

  ingress {
    description      = "web from VPC"
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
    Name = "allow_web"
  }
}


output "ami_return" {
  value = data.aws_ami.amzn2.id
}

output "vpc_id" {
  value = var.vpc_id
}