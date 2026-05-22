variable "name" {
  description = "Name prefix for resources."
  type        = string
}

variable "vpc_id" {
  description = "VPC where CloudBeaver EC2 will be deployed."
  type        = string
}

variable "subnet_id" {
  description = "Subnet ID for the CloudBeaver EC2 instance (usually a public subnet for direct internet access)."
  type        = string
}

variable "associate_public_ip_address" {
  description = "Whether to assign a public IPv4 to the instance (required for direct browser access without SSM)."
  type        = bool
  default     = true
}

variable "allowed_ingress_cidrs" {
  description = "CIDRs allowed to reach CloudBeaver from the internet. Required unless enable_ssm_only=true."
  type        = list(string)
  default     = []

  validation {
    condition     = var.enable_ssm_only || length(var.allowed_ingress_cidrs) > 0
    error_message = "If enable_ssm_only=false, you must set allowed_ingress_cidrs (do not leave CloudBeaver exposed)."
  }
}

variable "cloudbeaver_image" {
  description = "Docker image for CloudBeaver."
  type        = string
  default     = "dbeaver/cloudbeaver:latest"
}

variable "cloudbeaver_port" {
  description = "Port exposed on the EC2 instance for CloudBeaver (container listens on 8978)."
  type        = number
  default     = 8978
}

variable "postgres_port" {
  description = "Port exposed on the EC2 instance for PostgreSQL (container listens on 5432)."
  type        = number
  default     = 5432
}

variable "instance_type" {
  description = "EC2 instance type."
  type        = string
  default     = "t3.micro"
}

variable "architecture" {
  description = "AMI architecture: x86_64 or arm64."
  type        = string
  default     = "x86_64"
  validation {
    condition     = contains(["x86_64", "arm64"], var.architecture)
    error_message = "architecture must be x86_64 or arm64."
  }
}

variable "ami_id" {
  description = "Optional AMI ID. If null, the latest Amazon Linux 2023 is used via SSM parameter."
  type        = string
  default     = null
}

variable "root_volume_gb" {
  description = "Root EBS volume size in GB."
  type        = number
  default     = 20
}

variable "key_name" {
  description = "Optional EC2 key pair name (only needed if you want SSH)."
  type        = string
  default     = null
}

variable "enable_ssh" {
  description = "Whether to open SSH (22) to the instance. Prefer SSM instead."
  type        = bool
  default     = false
}

variable "ssh_ingress_cidrs" {
  description = "CIDRs allowed to SSH (only used if enable_ssh=true)."
  type        = list(string)
  default     = []
}

variable "enable_ssm" {
  description = "Attach IAM permissions for AWS Systems Manager Session Manager."
  type        = bool
  default     = true
}

variable "enable_ssm_only" {
  description = "If true, do not open CloudBeaver inbound from the internet; access via SSM port-forwarding instead."
  type        = bool
  default     = false
}

variable "ttl_minutes" {
  description = "Optional auto-terminate after N minutes. 0 disables. Requires instance_initiated_shutdown_behavior=terminate."
  type        = number
  default     = 0
}

variable "create_eip" {
  description = "Whether to allocate and associate an Elastic IP (stable public IPv4 while the instance exists)."
  type        = bool
  default     = false
}

variable "db_access_rules" {
  description = <<EOT
List of ingress exceptions to add to database security groups so CloudBeaver can connect.
Each item: { security_group_id = string, port = number, protocol = optional(string), description = optional(string) }
Note: SG-to-SG references require the DB SG to be in the SAME VPC as CloudBeaver.
EOT
  type = list(object({
    security_group_id = string
    port              = number
    protocol          = optional(string, "tcp")
    description       = optional(string, "From CloudBeaver")
  }))
  default = []
}

variable "tags" {
  description = "Additional tags."
  type        = map(string)
  default     = {}
}

variable "region" {
  description = "AWS region to deploy resources in."
  type        = string
  default     = "us-east-1"
}