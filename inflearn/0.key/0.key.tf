provider "aws" {
  region = "ap-northeast-2"
}

resource "aws_key_pair" "terraform-key-pair" {
  key_name   = "tf-key-pair"
  # public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQDVgGLhCXeSa73O96ULLXiYNnrB8VQRvLPPIfFvXabx300ZHbNbUz4spQ9esETCjddk9LxyzVqqDKcMMc9gcqn+uAm/7AUmelgsKskPChc5xUnACszozCQpXbbiLRwz+Nm7XFbZNXqzJ5Y4z+DmpB7gxGdr21TV5xS0wFPilLgRGyo37Ry8x7EOxIQK43qYkVbhxAuLIpOvs84OW7Br9K/K2h8LxdhcmM4EeyQ4/Q+TNDTLvU5s3e2Y/JHExh1EnNJNUrGIlQ9DeyRldfByqiO8FbYD/+6DGWXX7A9N/JjI6TQmboaY1hpT7nrlhsGsIYQeGoWLzibrjdlSwuwRUNVv2zBnfXA+vVNdPIkwllOnonfS7t+JpYQPA1lYt8NI+4BLMubjIZGP20IOR9XGgtpT8i9HQfgB8q+boskVad3zW8qCV5n4rz01cMHx/5i1ueeE3/3vdwIMt8N9jODVLvR0cXEW9SBlibygyZUlCb8L7tdg6jYYGT1sBaFJj9alO43r7y5fTjf3IOsPhKIFg8daqN0tTqxkUbD1K/bcLLWf4L9S7rVCu6nVGPowUgTNIlFuYt9HLR8UE5WnlLVGkbGp/psDySmLx2r3n1gaLllPmUVYWBTcWxiMhKiWVZ6fDf2jLAblhHvdOdHRyVKLOkBkenORwyyhWe+H080wAQJygw=="
  public_key = file("/Users/ygtoken/.ssh/tf-key-pair.pub")
}



