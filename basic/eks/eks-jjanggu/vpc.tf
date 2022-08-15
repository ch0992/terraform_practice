resource "aws_vpc" "terraform-eks-vpc" {
  cidr_block = "10.110.0.0/16"

  tags = {
    "Name" = "terraform-eks-node"
    # "kubernetes.io/cluster/${var.cluster-name}" = "shared"   
  }
}


#create subnet
resource "aws_subnet" "terraform-eks-public-subnet" {
  count=2

  availability_zone = data.aws_availability_zones.available.names[count.index]
  cidr_block = "10.110${count.index+1}.0/24"
  map_public_ip_on_launch = true
  vpc_id     = aws_vpc.terraform-eks-vpc.id

  tags = {
    "Name" = "terraform-eks-public-${count.index+1 == 1 ? "a":"c"}"
    # "kubernetes.io/cluster/${var.cluster-name}" = "shared"
  }
}

resource "aws_internet_gateway" "terraform-eks-igw" {
  vpc_id = aws_vpc.terraform-eks-vpc.id

  tags = {
    Name = "terraform-eks-igw"
  }
}

#create route table
resource "aws_route_table" "terraform-eks-public-route" {
  vpc_id = aws_vpc.terraform-eks-vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.terraform-eks-igw.id
  }

  tags = {
    "Name" = "terraform-eks-public"
  }
}


#create route table association
#Subnet과 Route table을 연결
resource "aws_route_table_association" "terraform-eks-public-routing" {
  count = 2
  subnet_id = aws_subnet.terraform-eks-public-subnet.*.id[count.index]
  route_table_id = aws_route_table.terraform-eks-public-route.id 
}
