locals {
  tags = merge(
    var.tags,
    {
      Name      = var.name
      ManagedBy = "terraform"
    }
  )

  al2023_ssm_param = var.architecture == "arm64" ? "/aws/service/ami-amazon-linux-latest/al2023-ami-kernel-default-arm64" : "/aws/service/ami-amazon-linux-latest/al2023-ami-kernel-default-x86_64"
}