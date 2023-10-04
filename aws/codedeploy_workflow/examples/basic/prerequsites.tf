### Prerequsite 

data "aws_ami" "amazon-linux" {
  most_recent = true
  filter {
    name   = "owner-alias"
    values = ["amazon"]
  }
  filter {
    name   = "name"
    values = ["al2023-ami-kernel-*-x86_64"]
  }
}

resource "aws_launch_template" "main" {
  name_prefix   = "foobar"
  image_id      = data.aws_ami.amazon-linux.image_id
  instance_type = "t2.micro"
}

resource "aws_autoscaling_group" "main" {
  availability_zones = ["eu-west-1a"]
  desired_capacity   = 1
  max_size           = 1
  min_size           = 1

  launch_template {
    id      = aws_launch_template.main.id
    version = "$Latest"
  }
}

resource "aws_codecommit_repository" "main" {
  repository_name = "${local.name}-repo"
  description     = "This is a demo repository"
}