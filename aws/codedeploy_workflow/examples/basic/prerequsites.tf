### Prerequsites

data "aws_ami" "amazon-linux" {
  most_recent = true
  filter {
    name   = "owner-alias"
    values = ["amazon"]
  }
  filter {
    name   = "name"
    values = ["al2023-ami-202*-kernel-6.1-x86_64"]
  }
}

data "aws_availability_zones" "available" {}

module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "5.1.2"

  name               = "${local.name}-vpc"
  cidr               = local.vpc_cidr
  azs                = slice(data.aws_availability_zones.available.names, 0, 3)
  private_subnets    = [for k, v in slice(data.aws_availability_zones.available.names, 0, 3) : cidrsubnet(local.vpc_cidr, 4, k)]
  public_subnets     = [for k, v in slice(data.aws_availability_zones.available.names, 0, 3) : cidrsubnet(local.vpc_cidr, 4, k + 4)]
  enable_nat_gateway = true
}

resource "aws_launch_template" "main" {
  name_prefix   = "foobar"
  image_id      = data.aws_ami.amazon-linux.image_id
  instance_type = "t2.micro"
  user_data     = filebase64("${path.module}/userdata.sh")

  iam_instance_profile {
    arn = aws_iam_instance_profile.main.arn
  }
}

resource "aws_autoscaling_group" "main" {
  desired_capacity    = 1
  max_size            = 1
  min_size            = 1
  vpc_zone_identifier = module.vpc.private_subnets

  launch_template {
    id      = aws_launch_template.main.id
    version = "$Latest"
  }
}

data "aws_iam_policy_document" "assume_role_policy" {
  statement {
    effect = "Allow"
    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
    actions = ["sts:AssumeRole"]
  }
}

resource "aws_iam_role" "main" {
  name               = "${local.name}-role"
  assume_role_policy = data.aws_iam_policy_document.assume_role_policy.json
}
resource "aws_iam_instance_profile" "main" {
  name = "${local.name}-profile"
  role = aws_iam_role.main.name
}

resource "aws_iam_role_policy_attachment" "ssm" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
  role       = aws_iam_role.main.name
}