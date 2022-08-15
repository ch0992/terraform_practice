locals {
  app_name = "simple-test"
}

resource "aws_ecr_repository" "simple_test" {
  name = local.app_name
}

