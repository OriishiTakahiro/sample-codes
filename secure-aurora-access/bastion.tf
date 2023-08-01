# ---------------------
# EC2インスタンス
# ---------------------

resource "aws_instance" "bastion" {
  # Amazon Linux 2023
  ami                    = "ami-0d3bbfd074edd7acb"
  iam_instance_profile   = aws_iam_instance_profile.bastion.name
  instance_type          = "t2.micro"
  subnet_id              = aws_subnet.local_1a.id
  vpc_security_group_ids = [aws_security_group.bastion.id]

  # デフォルトでは起動していない
  user_data                   = <<EOS
#!/bin/bash
sudo systemctl enable amazon-ssm-agent
sudo systemctl start amazon-ssm-agent
EOS
  user_data_replace_on_change = true

  tags = {
    Name = "bastion"
  }
}

# ---------------------
# IAM Role
# ---------------------

data "aws_iam_policy_document" "bastion_assume_role" {
  statement {
    effect = "Allow"
    actions = [
      "sts:AssumeRole",
    ]
    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

data "aws_iam_policy" "ssm_core" {
  arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource "aws_iam_role_policy" "bastion_ssm_core" {
  name   = "bastion-policy"
  role   = aws_iam_role.bastion.name
  policy = data.aws_iam_policy.ssm_core.policy
}

resource "aws_iam_role" "bastion" {
  name               = "bastion"
  path               = "/"
  assume_role_policy = data.aws_iam_policy_document.bastion_assume_role.json
}

resource "aws_iam_instance_profile" "bastion" {
  name = "bastion"
  role = aws_iam_role.bastion.name
}

# ---------------------
# Security Group
# ---------------------

resource "aws_security_group" "bastion" {
  name        = "bastion"
  description = "bastion"
  vpc_id      = aws_vpc.main.id

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
