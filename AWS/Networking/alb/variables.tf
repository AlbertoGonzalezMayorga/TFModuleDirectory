variable "name" {
  description = "Load balancer name."
  type        = string
}

variable "vpc_id" {
  description = "VPC ID."
  type        = string
}

variable "subnet_ids" {
  description = "Subnet IDs for the load balancer."
  type        = list(string)
}

variable "load_balancer_type" {
  description = "Load balancer type."
  type        = string
  default     = "application"
}

variable "internal" {
  description = "Whether the load balancer is internal."
  type        = bool
  default     = false
}

variable "security_group_ids" {
  description = "Existing security groups to attach."
  type        = list(string)
  default     = []
}

variable "create_security_group" {
  description = "Whether to create a security group for the ALB."
  type        = bool
  default     = true
}

variable "security_group_name" {
  description = "Security group name."
  type        = string
  default     = null
}

variable "security_group_description" {
  description = "Security group description."
  type        = string
  default     = "Security group managed by Terraform."
}

variable "security_group_tags" {
  description = "Additional security group tags."
  type        = map(string)
  default     = {}
}

variable "security_group_ingress_rules" {
  description = "Ingress rules for the created security group."
  type = map(object({
    description                  = optional(string, null)
    from_port                    = number
    to_port                      = number
    ip_protocol                  = string
    cidr_ipv4                    = optional(string, null)
    referenced_security_group_id = optional(string, null)
  }))
  default = {}
}

variable "security_group_egress_rules" {
  description = "Egress rules for the created security group."
  type = map(object({
    description = optional(string, null)
    from_port   = optional(number, null)
    to_port     = optional(number, null)
    ip_protocol = string
    cidr_ipv4   = optional(string, "0.0.0.0/0")
  }))
  default = {
    all = {
      ip_protocol = "-1"
      cidr_ipv4   = "0.0.0.0/0"
    }
  }
}

variable "enable_deletion_protection" {
  description = "Enable deletion protection."
  type        = bool
  default     = false
}

variable "drop_invalid_header_fields" {
  description = "Drop invalid HTTP headers."
  type        = bool
  default     = true
}

variable "enable_cross_zone_load_balancing" {
  description = "Enable cross-zone load balancing."
  type        = bool
  default     = true
}

variable "access_logs" {
  description = "Access logs configuration."
  type = object({
    bucket  = string
    enabled = optional(bool, true)
    prefix  = optional(string, null)
  })
  default = null
}

variable "target_groups" {
  description = "Target groups keyed by name."
  type = map(object({
    port        = number
    protocol    = optional(string, "HTTP")
    target_type = optional(string, "instance")
    tags        = optional(map(string), {})
    health_check = optional(object({
      enabled             = optional(bool, true)
      healthy_threshold   = optional(number, 2)
      interval            = optional(number, 30)
      matcher             = optional(string, "200-399")
      path                = optional(string, "/")
      port                = optional(string, "traffic-port")
      protocol            = optional(string, "HTTP")
      timeout             = optional(number, 5)
      unhealthy_threshold = optional(number, 2)
    }), {})
  }))
  default = {}
}

variable "listeners" {
  description = "Listeners keyed by name."
  type = map(object({
    port             = number
    protocol         = optional(string, "HTTP")
    certificate_arn  = optional(string, null)
    ssl_policy       = optional(string, null)
    target_group_key = string
  }))
  default = {}
}

variable "tags" {
  description = "Tags applied to all supported resources."
  type        = map(string)
  default     = {}
}
