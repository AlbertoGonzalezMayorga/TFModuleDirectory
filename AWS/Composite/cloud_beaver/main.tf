data "aws_ssm_parameter" "al2023" {
  count = var.ami_id == null ? 1 : 0
  name  = local.al2023_ssm_param
}

resource "aws_iam_role" "ssm" {
  count = var.enable_ssm ? 1 : 0

  name = "${var.name}-ssm-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action    = "sts:AssumeRole"
      Effect    = "Allow"
      Principal = { Service = "ec2.amazonaws.com" }
    }]
  })

  tags = local.tags
}

resource "aws_iam_role_policy_attachment" "ssm_core" {
  count      = var.enable_ssm ? 1 : 0
  role       = aws_iam_role.ssm[0].name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource "aws_iam_instance_profile" "ssm" {
  count = var.enable_ssm ? 1 : 0
  name  = "${var.name}-ssm-profile"
  role  = aws_iam_role.ssm[0].name
  tags  = local.tags
}

resource "aws_security_group" "cloudbeaver" {
  name        = "${var.name}-sg"
  description = "CloudBeaver access"
  vpc_id      = var.vpc_id

  dynamic "ingress" {
    for_each = var.enable_ssm_only ? [] : [1]
    content {
      description = "CloudBeaver web"
      from_port   = var.cloudbeaver_port
      to_port     = var.cloudbeaver_port
      protocol    = "tcp"
      cidr_blocks = var.allowed_ingress_cidrs
    }
  }

  dynamic "ingress" {
    for_each = var.enable_ssh ? [1] : []
    content {
      description = "SSH access"
      from_port   = 22
      to_port     = 22
      protocol    = "tcp"
      cidr_blocks = var.ssh_ingress_cidrs
    }
  }

  egress {
    description = "All egress"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = local.tags
}

resource "aws_instance" "cloudbeaver" {
  ami                         = var.ami_id != null ? var.ami_id : data.aws_ssm_parameter.al2023[0].value
  instance_type               = var.instance_type
  subnet_id                   = var.subnet_id
  vpc_security_group_ids      = [aws_security_group.cloudbeaver.id]
  associate_public_ip_address = var.associate_public_ip_address
  key_name                    = var.key_name

  iam_instance_profile = var.enable_ssm ? aws_iam_instance_profile.ssm[0].name : null

  instance_initiated_shutdown_behavior = var.ttl_minutes > 0 ? "terminate" : "stop"

  root_block_device {
    volume_size = var.root_volume_gb
    volume_type = "gp3"
  }

  user_data = <<-EOF
    #!/bin/bash
    set -euxo pipefail

    dnf update -y
    dnf install -y docker
    systemctl enable --now docker

    mkdir -p /opt/cloudbeaver/workspace

    # (Re)start CloudBeaver
    docker rm -f cloudbeaver || true
    docker pull ${var.cloudbeaver_image}
    docker run -d --name cloudbeaver --restart unless-stopped \
      -p ${var.cloudbeaver_port}:8978 \
      -v /opt/cloudbeaver/workspace:/opt/cloudbeaver/workspace \
      ${var.cloudbeaver_image}

    # Optional TTL auto-termination
    if [ "${var.ttl_minutes}" -gt 0 ]; then
      shutdown -h +${var.ttl_minutes}
    fi
  EOF

  tags = local.tags
}

resource "aws_eip" "cloudbeaver" {
  count  = var.create_eip ? 1 : 0
  domain = "vpc"
  tags   = local.tags
}

resource "aws_eip_association" "cloudbeaver" {
  count         = var.create_eip ? 1 : 0
  allocation_id = aws_eip.cloudbeaver[0].id
  instance_id   = aws_instance.cloudbeaver.id
}

resource "aws_security_group_rule" "db_ingress" {
  for_each = {
    for idx, r in var.db_access_rules : idx => r
  }

  type                     = "ingress"
  security_group_id        = each.value.security_group_id
  from_port                = each.value.port
  to_port                  = each.value.port
  protocol                 = each.value.protocol
  description              = each.value.description
  source_security_group_id = aws_security_group.cloudbeaver.id
}
