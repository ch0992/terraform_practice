provider "aws" {
  region = "ap-northeast-2"
}

resource "aws_security_group" "instance" {
  name = "terraform-example-instance"
  vpc_id = "vpc-00efe79d97c1b84b9"
  ingress {
    from_port = 8080
    to_port = 8080
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_instance" "example" {
  ami = "ami-37b91959"
  instance_type = "t2.micro"
  subnet_id = "subnet-011a779a744db95d6"
  vpc_security_group_ids = ["{aws_security_group.instance.id}"]

  user_data = <<-EOF
              #!/bin/bash
              echo "Hello. World" > index.html
              nohup busybox httpd -f -p 8080 &
              EOF
  tags = {
    Name = "terraform-example"
  }              
}


output "public_ip" {
  value = aws_instance.example.public_ip
}
