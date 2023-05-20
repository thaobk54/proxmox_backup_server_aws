provider "aws" {
  region  = "ap-southeast-1"
  profile = "ops_tf"
}

### Resources

resource "aws_security_group" "allow_proxmox_remote" {
  name_prefix = "proxmox-remote"
  vpc_id      = aws_default_vpc.default.id

  ingress {
    from_port = 8007
    to_port   = 8007
    protocol  = "tcp"
    cidr_blocks = [
      "0.0.0.0/0",
    ]
  }
  ingress {
    from_port = 22
    to_port   = 22
    protocol  = "tcp"
    cidr_blocks = [
      "14.161.17.5/32",
    ]
  }
  #all outbound
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  lifecycle {
    create_before_destroy = true
  }

  tags = local.tags
}

module "ec2_instance" {
  source  = "terraform-aws-modules/ec2-instance/aws"
  version = "~> 3.0"

  name = var.node_name

  ami                         = data.aws_ami.debian-11.id
  instance_type               = "t3.small"
  monitoring                  = true
  vpc_security_group_ids      = [aws_security_group.allow_proxmox_remote.id]
  subnet_id                   = data.aws_subnet.default.id
  associate_public_ip_address = true
  key_name               = aws_key_pair.deployer.key_name

  iam_instance_profile = aws_iam_instance_profile.ssm-iam-profile.name

  tags = merge(local.tags, {
    Name = var.node_name
  })
}

resource "aws_volume_attachment" "this" {
  device_name = "/dev/sdh"
  volume_id   = aws_ebs_volume.this.id
  instance_id = module.ec2_instance.id
}

resource "aws_ebs_volume" "this" {
  availability_zone = data.aws_subnet.default.availability_zone
  size              = 30

  tags = local.tags
}
resource "aws_iam_instance_profile" "ssm-iam-profile" {
  name = "ssm_ec2_profile"
  role = aws_iam_role.ssm-role.name
}
resource "aws_iam_role" "ssm-role" {
  name               = "proxmox-backup-ssm-role"
  description        = "The role for the developer resources EC2"
  assume_role_policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Action": "sts:AssumeRole",
            "Principal": {
               "Service": "ec2.amazonaws.com"
            },
            "Effect": "Allow",
            "Sid": ""
        }
    ]
}
EOF
}
resource "aws_iam_role_policy_attachment" "resources-ssm-policy" {
  role       = aws_iam_role.ssm-role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource "aws_key_pair" "deployer" {
  key_name   = "deployer-key"
  public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQDS4ziM9n+Wk1GWAUyhILq2YKTjjJXvPa7U4DUxMx1s1Ycuug8//O9YIr4wDpGPTkg5FpzgCEnJH+VTkuTJrXjKLh17il1LveXhniifjLA1hDHfA34e8obLoiXpkBEobXjXuUCJCZEpcR1z3VpUrjbyQk0K4eIzf0+cjoMTeugcMJjfFF2r9Cin1NgwcqRjHB+Gl5V1nELJ+saq3qeoTVBZCdIztHZGUXedJyf+fMJofr5hCVJWoD9+V6DdM/Iu04x7duGoTP+qTbxf/lJcNxwZW1b6KP2SX4lZ8Ib6M4e686sisA4RD1Qk0QCdUyIHGFOXlySuNrhmEkmY2pySub2Ltm7OcOBL1DpI95iEFcspmYU7BVvrHGCt14iTP5CguqH8taKKvtOND+PM5mf9AsvmKjFb17/8GMMYWr2Ys4JgdwNDxRVWN1ajHs2uFe6Qh+K6Mf/exSLOKEs63YAdAbNodhvRC2/C1y3h8R9/RhnYb2Xya7a30g04PZqs3pGO2fwlzx2UiW2OIrPk9XW0lAybmBStJn/Slu8vA93jxXumjDEC72hp/x77F6xpJpO+QFRYEiIKq+dp77zgNVosjFDqFYBY+MyPSnz/UnqbyIhv+1yWubbdifVLg5mSlmGMBs7rIS55Q/8nuS4YOaDwjSetVs9kUq8Uk8Nnn0sp+2w7DQ=="
}