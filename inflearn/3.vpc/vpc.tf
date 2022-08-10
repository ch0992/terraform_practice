provider "aws" {
  region = "ap-northeast-2"
}

/*
vpc 네이밍 룰
프로젝트명(ec)-스테이지명(prd)-사용하는서비스(was)-vpc-ip
*/

resource "aws_vpc" "vpc-10-0-0-0" {
  cidr_block       = "10.0.0.0/16"
  instance_tenancy = "default"
  enable_dns_hostnames = true

  tags = {
    Name = "vpc-10-0-0-0"
  }
}

resource "aws_subnet" "sub-pub1-10-0-1-0" {
  vpc_id     = aws_vpc.vpc-10-0-0-0.id
  cidr_block = "10.0.1.0/24"
  availability_zone = "ap-northeast-2a"
  map_public_ip_on_launch = true

  tags = {
    Name = "sub-pub1-10-0-1-0"
  }
}

resource "aws_subnet" "sub-pub2-10-0-2-0" {
  vpc_id     = aws_vpc.vpc-10-0-0-0.id
  cidr_block = "10.0.2.0/24"
  availability_zone = "ap-northeast-2c"
  map_public_ip_on_launch = true
  
  tags = {
    Name = "sub-pub2-10-0-2-0"
  }
}

resource "aws_subnet" "sub-pri1-10-0-3-0" {
  vpc_id     = aws_vpc.vpc-10-0-0-0.id
  cidr_block = "10.0.3.0/24"
  availability_zone = "ap-northeast-2a"
  
  tags = {
    Name = "sub-pri1-10-0-3-0"
  }
}

resource "aws_subnet" "sub-pri2-10-0-4-0" {
  vpc_id     = aws_vpc.vpc-10-0-0-0.id
  cidr_block = "10.0.4.0/24"
  availability_zone = "ap-northeast-2c"
  
  tags = {
    Name = "sub-pri2-10-0-4-0"
  }
}

resource "aws_internet_gateway" "igw-vpc-10-0-0-0" {
  vpc_id = aws_vpc.vpc-10-0-0-0.id

  tags = {
    Name = "igw-vpc-10-0-0-0"
  }
}

resource "aws_route_table" "rt-pub-vpc-10-0-0-0" {
  vpc_id = aws_vpc.vpc-10-0-0-0.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw-vpc-10-0-0-0.id
  }

  tags = {
    Name = "rt-pub-vpc-10-0-0-0"
  }
}

resource "aws_route_table_association" "rt-pub-as1-vpc-10-0-0-0" {
  subnet_id      = aws_subnet.sub-pub1-10-0-1-0.id
  route_table_id = aws_route_table.rt-pub-vpc-10-0-0-0.id
}

resource "aws_route_table_association" "rt-pub-as2-vpc-10-0-0-0" {
  subnet_id      = aws_subnet.sub-pub2-10-0-2-0.id
  route_table_id = aws_route_table.rt-pub-vpc-10-0-0-0.id
}


resource "aws_route_table" "rt-pri1-vpc-10-0-0-0" {
  vpc_id = aws_vpc.vpc-10-0-0-0.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_nat_gateway.natgw-2c.id
  }

  tags = {
    Name = "rt-pri1-vpc-10-0-0-0"
  }
}

resource "aws_route_table" "rt-pri2-vpc-10-0-0-0" {
  vpc_id = aws_vpc.vpc-10-0-0-0.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_nat_gateway.natgw-2c.id
  }

  tags = {
    Name = "rt-pri2-vpc-10-0-0-0"
  }
}

resource "aws_route_table_association" "rt-pri1-as1-vpc-10-0-0-0" {
  subnet_id      = aws_subnet.sub-pri1-10-0-3-0.id
  route_table_id = aws_route_table.rt-pri1-vpc-10-0-0-0.id
}

resource "aws_route_table_association" "rt-pri2-as2-vpc-10-0-0-0" {
  subnet_id      = aws_subnet.sub-pri2-10-0-4-0.id
  route_table_id = aws_route_table.rt-pri2-vpc-10-0-0-0.id
}


resource "aws_eip" "nat-2a" {
  vpc      = true
}

resource "aws_eip" "nat-2c" {
  vpc      = true
}

resource "aws_nat_gateway" "natgw-2a" {
  allocation_id = aws_eip.nat-2a.id
  subnet_id     = aws_subnet.sub-pub1-10-0-1-0.id

  tags = {
    Name = "gw NAT-2a"
  }
}


resource "aws_nat_gateway" "natgw-2c" {
  allocation_id = aws_eip.nat-2c.id
  subnet_id     = aws_subnet.sub-pub2-10-0-2-0.id

  tags = {
    Name = "gw NAT-2c"
  }
}

