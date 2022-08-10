resource "aws_vpc" "simple_vpc" {
  cidr_block = "10.0.0.0/16"

  tags = {
    Name = "simple_vpc"
  }
}

resource "aws_subnet" "public_subnet1" {
  vpc_id     = aws_vpc.simple_vpc.id
  cidr_block = "10.0.0.0/24"

  availability_zone = "ap-northeast-2a"
  
  tags = {
    Name = "public_subnet1"
  }
}

resource "aws_subnet" "public_subnet2" {
  vpc_id     = aws_vpc.simple_vpc.id
  cidr_block = "10.0.1.0/24"

  availability_zone = "ap-northeast-2b"

  tags = {
    Name = "public_subnet2"
  }
}

resource "aws_internet_gateway" "IGW" {
  vpc_id = aws_vpc.simple_vpc.id

  tags = {
    Name = "simple_vpc_IGW"
  }
}

resource "aws_route_table" "public_rt" {
  vpc_id = aws_vpc.simple_vpc.id

  tags = {
    Name = "public_rt"
  }
}

resource "aws_route_table_association" "public_rt_association_1" {
  subnet_id      = aws_subnet.public_subnet1.id
  route_table_id = aws_route_table.public_rt.id
}

resource "aws_route_table_association" "public_rt_association_2" {
  subnet_id      = aws_subnet.public_subnet2.id
  route_table_id = aws_route_table.public_rt.id
}

resource "aws_subnet" "private_subnet1" {
  vpc_id     = aws_vpc.simple_vpc.id
  cidr_block = "10.0.2.0/24"

  availability_zone = "ap-northeast-2a"

  tags = {
    Name = "private_subnet1"
  }
}

resource "aws_subnet" "private_subnet2" {
  vpc_id     = aws_vpc.simple_vpc.id
  cidr_block = "10.0.3.0/24"

  availability_zone = "ap-northeast-2b"

  tags = {
    Name = "private_subnet2"
  }
}

resource "aws_eip" "nat_ip" {
  vpc   = true

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_nat_gateway" "nat_gateway" {
  allocation_id = aws_eip.nat_ip.id

  subnet_id = aws_subnet.public_subnet1.id

  tags = {
    Name = "NAT_gateway"
  }
}

resource "aws_route_table" "private_rt" {
  vpc_id = aws_vpc.simple_vpc.id

  tags = {
    Name = "private_rt"
  }
}

resource "aws_route_table_association" "private_rt_association1" {
  subnet_id      = aws_subnet.private_subnet1.id
  route_table_id = aws_route_table.private_rt.id
}

resource "aws_route_table_association" "private_rt_association2" {
  subnet_id      = aws_subnet.private_subnet2.id
  route_table_id = aws_route_table.private_rt.id
}

resource "aws_route" "private_rt_nat" {
  route_table_id              = aws_route_table.private_rt.id
  destination_cidr_block      = "0.0.0.0/0"
  nat_gateway_id              = aws_nat_gateway.nat_gateway.id
}


resource "aws_security_group" "instance" {
  name = "terraform-example-instance"
  vpc_id = aws_vpc.simple_vpc.id
  ingress {
    from_port = 8080
    to_port = 8080
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}


resource "aws_instance" "example" {
  ami = "ami-0e17ad9abf7e5c818"
  instance_type = "t2.micro"
  subnet_id = aws_subnet.public_subnet1.id
  vpc_security_group_ids = ["${aws_security_group.instance.id}"]
  associate_public_ip_address = true
  user_data = <<-EOF
              #!/bin/bash
              echo "Hello. World" > index.html
              nohup busybox httpd -f -p 8080 &
              EOF
  tags = {
    Name = "terraform-example"
  }              
}

output "public_ip" {
  value = aws_instance.example.public_ip
}








