provider "aws" {
  region = "ap-northeast-2"
}

locals{
    vpc_name = "simple-test"
    cidr = "10.194.0.0/16"
    public_subnets = ["10.194.0.0/24", "10.194.1.0/24"]
    private_subnets = ["10.194.100.0/24","10.194.101.0/24"]
    azs = ["ap-northeast-2a","ap-northeast-2c"]
    cluster_name = "simple-test"
}

## vpc 생성
resource "aws_vpc" "this" {
  cidr_block = local.cidr
  tags = {Name = local.vpc_name}
}

## VPC 생성 시 기본으로 생성되는 보안 그룹에 이름을 붙임
resource "aws_default_security_group" "this" {
  vpc_id = aws_vpc.this.id
  tags = {
    Name = "${local.vpc_name}-default"
  }
}

## 퍼블릭 서브넷에 연결할 인터넷 게이트 웨이를 정의
resource "aws_internet_gateway" "this" {
  vpc_id = aws_vpc.this.id
  tags = {
    Name = "${local.vpc_name}-igw"
  }
}

## 퍼블릭 서브넷에 적용할 라우팅 테이블
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.this.id
  tags = {
    Name = "${local.vpc_name}-public"
  }
}

## 퍼블릭 서브넷에서 인터넷에 트래픽 요청 시 앞서 정의한 인터넷 게이트웨이로 보냄
resource "aws_route" "public_worldwide" {
  route_table_id = aws_route_table.public.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id = aws_internet_gateway.this.id
}


## 퍼블릭 서브넷을 정의합니다
resource "aws_subnet" "public" {
  count = length(local.public_subnets)  #한번에 모든 서브넷을 정의

  vpc_id = aws_vpc.this.id
  cidr_block = local.public_subnets[count.index]
  availability_zone = local.azs[count.index]
  map_public_ip_on_launch = true # 퍼블릭 서브넷에 배치되는 서비스는 자동으로 공개 IP를 부여한다.

  tags = {
    Name = "${local.vpc_name}-public-${count.index + 1}",
    "kubernetes.io/cluster/${local.cluster_name}" = "shared", # 다른 부분
    "kubernetes.io/role/elb" = "1"
  }
}

## 퍼블릭 서브넷을 라우팅 테이블에 연결한다.
resource "aws_route_table_association" "public" {
  count = length(local.public_subnets)

  subnet_id = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public.id
}

## NAT 게이트웨이는 고정 IP를 필요로 함
resource "aws_eip" "nat_gateway" {
  vpc = true
  tags = {
    Name = "${local.vpc_name}-natgw"
  }
}


## 프라이빗 서브넷에서 인터넷 접속 시 사용할  NAT 게이트웨이
resource "aws_nat_gateway" "this" {
  allocation_id = aws_eip.nat_gateway.id
  subnet_id = aws_subnet.public[0].id #NAT 게이트웨이는 퍼블릭 서브넷에 위치해야 한다.
  tags = {
    Name = "${local.vpc_name}-natgw"
  }
}

##프라이빗 서브넷에 적용할 라우팅 테이블
resource "aws_route_table" "private" {
  vpc_id = aws_vpc.this.id
  tags = {
    Name = "${local.vpc_name}-private"
  }
}


##프라이빗 서브넷에서 인터넷에 트래픽 요청 시 앞서 정의한 NAT 게이트웨이로 보낸다.
resource "aws_route" "private_worldwide" {
  route_table_id = aws_route_table.private.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id = aws_nat_gateway.this.id
}

##프라이빗 서브넷을 정의합니다.
resource "aws_subnet" "private" {
  count = length(local.private_subnets)

  vpc_id = aws_vpc.this.id
  cidr_block = local.private_subnets[count.index]
  availability_zone = local.azs[count.index]
  tags = {
    Name = "${local.vpc_name}-private-${count.index + 1}",
    "kubernetes.io/cluster/${local.cluster_name}" = "shared",
    "kubernetes.io/role/internal-elb" = "1"
  }
}

## 프라이빗 서브넷을 라우팅 테이블에 연결한다.
resource "aws_route_table_association" "private" {
  count = length(local.private_subnets)

  subnet_id = aws_subnet.private[count.index].id
  route_table_id = aws_route_table.private.id
}



output "count_print" {
    value = local.public_subnets[*]
}