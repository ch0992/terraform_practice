provider "aws" {
  region = "ap-northeast-2"
}


data "aws_instances" "test" {
  filter{
    name = "tag:Name"
    values = ["web-*"]
  }
}

resource "aws_ami_from_instance" "example" {
  for_each =  toset(data.aws_instances.test.ids)
  name               = each.value
  source_instance_id = each.value
  tags = {
    Name = "web-${each.key}"
  }
}
