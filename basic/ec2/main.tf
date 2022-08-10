provider "aws" {
  region = "ap-northeast-2"
}

resource "aws_instance" "testEC2" {
  ami = "ami-0e17ad9abf7e5c818"
  instance_type = "t2.micro"
  subnet_id = "subnet-017010aa0d4cbfd3f"
}
