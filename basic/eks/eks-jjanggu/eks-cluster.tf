#IAM role 생성
resource "aws_iam_role" "terraform-eks-cluster" {
  name = "terraform-eks-cluster"
  assume_role_policy = <<POLICY
  {
    "Version":"2012-10-17"
    "Statement" : [
        {
            "Effect":"Allow"
            "Principal":{
                "Service":"eks.amazon.com"
            },
            "Action": "sts:AssumeRole
        }
    ]
  }
  POLICY
}

# IAM Role에 policy를 추가
resource "aws_iam_role_policy_attachment" "terraform-eks-cluster-AmazonEKSClusterPolicy" {
    policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
    role = aws_iam_role.terraform-eks-cluster.name 
}

resource "aws_iam_role_policy_attachment" "terraform-eks-cluster-AmazonEKSVPCResourceController" {
    policy_arn = "arn:aws:iam::aws:policy/AmazonEKSVPCResourceController"
    role = aws_iam_role.terraform-eks-cluster.name
  
}


#security group을 생성
resource "aws_security_group" "terraform-eks-cluster" {
    name = "terraform-eks-cluster"
    description = "Cluster communication with worker noeds"
    vpc_id = aws_vpc.terraform-eks-vpc.id

    egress {
        from_port = 0
        to_port = 0
        protocol = -1
        cidr_blocks = ["0.0.0.0/0"]
    } 
    tags = {
        Name="terraform-eks-cluster"
    }

}

#security group의 ingress룰 추가
resource "aws_security_group_rule" "terraform-eks-cluster-ingress-workstation-https" {
  cidr_blocks = [local.workstation-external-cidr]
  description = "Allow workstation to communicate with the cluster API Server"
  from_port = 443
  protocol = "tcp"
  security_group_id = aws_security_group.terraform-eks-cluster.id
  to_port = 443
  type = "ingress"
}

#create Cluster
resource "aws_eks_cluster" "terraform-eks-cluster" {
  name = var.cluster-name
  role_arn = aws_iam_role.terraform-eks-cluster.arn
  version = "1.20"

  enabled_cluster_log_types = ["api","audit","authenticator","controllerManager","scheduler"]

  vpc_config {
    security_group_ids = [aws_security_group.terraform-eks-cluster.id]
    subnet_ids = concat(aws_subnet.terraform-eks-public-subnet[*].id, aws_subnet.terraform-eks-private-subnet[*].id) 
    endpoint_private_access = true
    endpoint_public_access = true
  }

  depends_on = [
    aws_iam_role_policy_attachment.terraform-eks-cluster-AmazonEKSClusterPolicy,
    aws_iam_role_policy_attachment.terraform-eks-cluster-AmazonEKSVPCResourceController
  ]
  output "subnet-id" {
    value = concat(aws_subnet.terraform-eks-public-subnet[*].id, aws_subnet.terraform-eks-private-subnet[*].id)
  }
}

