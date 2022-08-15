## 클러스터가 사용할 역할 정의
## AmazonEKSClusterPolicy와 AmazonEKSVPCResourceController를 포함

resource "aws_iam_role" "cluster" {
  name = "${local.cluster_name}-eks-cluster-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Sid    = ""
        Principal = {
          Service = "ec2.amazonaws.com"
        },
        Action = "sts:AssumeRole"
      }]
  })
}

## 생성된 policy를 attach
resource "aws_iam_role_policy_attachment" "cluster_AmazonEKSClusterPolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
  role = aws_iam_role.cluster.name
}

resource "aws_iam_role_policy_attachment" "cluster_AmazonEKSVPCResourceController" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSVPCResourceController"
  role = aws_iam_role.cluster.name
}

## EKS 클러스터 정의
resource "aws_eks_cluster" "this" {
  name = local.cluster_name
  role_arn = aws_iam_role.cluster.arn
  vpc_config {
    subnet_ids = aws_subnet.private[*].id
  }
  depends_on = [
    aws_iam_role_policy_attachment.cluster_AmazonEKSClusterPolicy,
    aws_iam_role_policy_attachment.cluster_AmazonEKSVPCResourceController
  ]
}


## Fargate에서 팟 배치시 사용하는 실행 역할을 정의
## AmazonEKSFargatePodExecutionRolePolicy를 포함

resource "aws_iam_role" "pod_execution" {
  name = "${local.cluster_name}-eks-pod-execution-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Effect = "Allow",
      Principal = {
        Service = "eks-fargate-pods.amazonaws.com"
      },
      Action = "sts:AssumeRole"
    }]
  })
}
resource "aws_iam_role_policy_attachment" "pod_execution_AmazonEKSFargatePodExecutionRolePolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSFargatePodExecutionRolePolicy"
  role       = aws_iam_role.pod_execution.name
}

## EKS 클러스터에 노드를 Fargate로 공급
## default/kube-system 네임스페이스를 가진 팟에 대해 적용

resource "aws_eks_fargate_profile" "default" {
  cluster_name = aws_eks_cluster.this.name
  fargate_profile_name = "fp-default"
  pod_execution_role_arn = aws_iam_role.pod_execution.arn
  subnet_ids = aws_subnet.private[*].id #프라이빗 서브넷만 사용 가능
  selector {
    namespace = "default"
  }
  selector {
    namespace = "kube-system"
  }
}
//테라폼으로 EKS 구축하기
//https://devblog.kakaostyle.com/ko/2022-03-31-3-build-eks-cluster-with-terraform/

//EKS를 사용해서 어플리케이션 서비스 하기
//https://devblog.kakaostyle.com/ko/2022-03-31-2-web-application-using-eks/