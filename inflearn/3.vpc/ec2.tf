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

resource "aws_instance" "bestion" {
  ami           = data.aws_ami.amzn2.id
  instance_type = "t2.micro"
  key_name = "tf-key-pair"
  vpc_security_group_ids = [aws_security_group.allow_web-sg.id]
  availability_zone = "ap-northeast-2a"
  subnet_id = aws_subnet.sub-pub1-10-0-1-0.id
  user_data = file("./userdata.sh")

  root_block_device {
    volume_size = 30
  }

  tags = {
    Name = "bestion"
  }
}


resource "aws_instance" "web-2a" {
  ami           = data.aws_ami.amzn2.id
  instance_type = "t2.micro"
  key_name = "tf-key-pair"
  vpc_security_group_ids = [aws_security_group.allow_web-sg.id]
  availability_zone = "ap-northeast-2a"
  subnet_id = aws_subnet.sub-pri1-10-0-3-0.id
  user_data = file("./userdata.sh")

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
  vpc_security_group_ids = [aws_security_group.allow_web-sg.id]
  availability_zone = "ap-northeast-2c"
  subnet_id = aws_subnet.sub-pri2-10-0-4-0.id
  user_data = file("./userdata.sh")

  root_block_device {
    volume_size = 30
  }

  tags = {
    Name = "web-2c"
  }
}



resource "aws_security_group" "allow_web-sg" {
  name        = "allow_web-sg"
  description = "Allow Web-sg inbound traffic"
  vpc_id      = aws_vpc.vpc-10-0-0-0.id

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
    Name = "allow_web-sg"
  }
}


output "ami_return" {
  value = data.aws_ami.amzn2.id
}

output "vpc_id" {
  value = aws_vpc.vpc-10-0-0-0.id
}
output "subnet_pub_01" {
  value = aws_subnet.sub-pub1-10-0-1-0.id
}
output "subnet_pub_02" {
  value = aws_subnet.sub-pub2-10-0-2-0.id
}
output "subnet_pri_01" {
  value = aws_subnet.sub-pri1-10-0-3-0.id
}
output "subnet_pri_02" {
  value = aws_subnet.sub-pri2-10-0-4-0.id
}