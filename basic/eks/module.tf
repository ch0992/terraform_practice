module "vpc" {
    source = "terraform-aws-modules/vpc/aws"
    name = "simon-test"
    cidr = "10.194.0.0/16"
    azs = ["ap-northeast-2a","ap-northeast-2c"]
    public_subnets = ["10.194.0.0/24","10.194.1.0/24"]
    private_subnets = ["10.194.100.0/24", "10.194.101.0/24"]

    enable_nat_gateway = true
    one_nat_gateway_per_az = true

    enable_dns_hostnames = true
    public_subnet_tags = {
        "kubernetes.io/cluster/${local.cluster.name}" = "shared"
        "kubernetes.io/role/elb" = "1"
    }
    private_subnet_tags = {
        "kubernetes.io/cluster/${local.cluster.name}" = "shared"
        "kubernetes.io/role/internal-elb" = "1"
    }
}

module "eks" {
    source = "terraform-aws-modules/eks/aws"

    cluster_name = local.cluster_name
    cluster_version = "1.21"
    cluster_endpoint_private_access = false
    cluster_endpoint_public_access = true

    cluster_addons = {
        coredns = {
            resolve_conflicts = "OVERWRITE"
        }
    }
    vpc_id = module.vpc.vpc_id
    subnets_ids = module.vpc.private_subnets
}