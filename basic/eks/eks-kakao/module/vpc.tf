
# kakaostyle 기술 블로그
#https://devblog.kakaostyle.com/ko/2022-03-31-3-build-eks-cluster-with-terraform/

provider "aws" {
  region = "ap-northeast-2"
}

locals {
  cluster_name = "simon-test"
}

module "vpc" {
  source = "terraform-aws-modules/vpc/aws"

  name = "simon-test"
  cidr = "10.194.0.0/16"

  azs             = ["ap-northeast-2a", "ap-northeast-2c"]
  public_subnets  = ["10.194.0.0/24", "10.194.1.0/24"]
  private_subnets = ["10.194.100.0/24", "10.194.101.0/24"]

  enable_nat_gateway     = true
  one_nat_gateway_per_az = true

  enable_dns_hostnames = true

  public_subnet_tags = {
    "kubernetes.io/cluster/${local.cluster_name}" = "shared"
    "kubernetes.io/role/elb"                      = "1"
  }

  private_subnet_tags = {
    "kubernetes.io/cluster/${local.cluster_name}" = "shared"
    "kubernetes.io/role/internal-elb"             = "1"
  }
}