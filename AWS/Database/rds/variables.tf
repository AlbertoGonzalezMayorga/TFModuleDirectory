variable "identifier" {
  description = "RDS instance identifier."
  type        = string
}

variable "engine" {
  description = "Database engine."
  type        = string
  default     = "postgres"
}

variable "engine_version" {
  description = "Database engine version."
  type        = string
  default     = null
}

variable "instance_class" {
  description = "RDS instance class."
  type        = string
  default     = "db.t3.micro"
}

variable "allocated_storage" {
  description = "Allocated storage in GB."
  type        = number
  default     = 20
}

variable "storage_type" {
  description = "Storage type."
  type        = string
  default     = "gp3"
}

variable "storage_encrypted" {
  description = "Whether storage is encrypted."
  type        = bool
  default     = true
}

variable "kms_key_id" {
  description = "KMS key ARN for storage encryption."
  type        = string
  default     = null
}

variable "username" {
  description = "Master username."
  type        = string
  default     = null
}

variable "password" {
  description = "Master password when manage_master_user_password is false."
  type        = string
  default     = null
  sensitive   = true
}

variable "manage_master_user_password" {
  description = "Whether AWS manages the master password in Secrets Manager."
  type        = bool
  default     = true
}

variable "db_name" {
  description = "Initial database name."
  type        = string
  default     = null
}

variable "subnet_ids" {
  description = "Subnet IDs for a created DB subnet group."
  type        = list(string)
  default     = []
}

variable "create_db_subnet_group" {
  description = "Whether to create a DB subnet group."
  type        = bool
  default     = true
}

variable "db_subnet_group_name" {
  description = "DB subnet group name to create or use."
  type        = string
  default     = null
}

variable "db_subnet_group_description" {
  description = "DB subnet group description."
  type        = string
  default     = "DB subnet group managed by Terraform."
}

variable "vpc_id" {
  description = "VPC ID for a created security group."
  type        = string
  default     = null
}

variable "create_security_group" {
  description = "Whether to create a security group."
  type        = bool
  default     = false
}

variable "security_group_name" {
  description = "Security group name."
  type        = string
  default     = null
}

variable "security_group_description" {
  description = "Security group description."
  type        = string
  default     = "RDS security group managed by Terraform."
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

variable "vpc_security_group_ids" {
  description = "Existing security group IDs."
  type        = list(string)
  default     = []
}

variable "create_parameter_group" {
  description = "Whether to create a DB parameter group."
  type        = bool
  default     = false
}

variable "parameter_group_name" {
  description = "Parameter group name to create or use."
  type        = string
  default     = null
}

variable "parameter_group_family" {
  description = "Parameter group family."
  type        = string
  default     = null
}

variable "parameter_group_description" {
  description = "Parameter group description."
  type        = string
  default     = "DB parameter group managed by Terraform."
}

variable "parameters" {
  description = "DB parameters."
  type = list(object({
    name         = string
    value        = string
    apply_method = optional(string, "immediate")
  }))
  default = []
}

variable "multi_az" {
  type    = bool
  default = false
}

variable "publicly_accessible" {
  type    = bool
  default = false
}

variable "deletion_protection" {
  type    = bool
  default = false
}

variable "skip_final_snapshot" {
  type    = bool
  default = true
}

variable "final_snapshot_identifier" {
  type    = string
  default = null
}

variable "copy_tags_to_snapshot" {
  type    = bool
  default = true
}

variable "backup_retention_period" {
  type    = number
  default = 7
}

variable "backup_window" {
  type    = string
  default = null
}

variable "maintenance_window" {
  type    = string
  default = null
}

variable "auto_minor_version_upgrade" {
  type    = bool
  default = true
}

variable "allow_major_version_upgrade" {
  type    = bool
  default = false
}

variable "enabled_cloudwatch_logs_exports" {
  type    = list(string)
  default = []
}

variable "iam_database_authentication_enabled" {
  type    = bool
  default = false
}

variable "monitoring_interval" {
  type    = number
  default = 0
}

variable "monitoring_role_arn" {
  type    = string
  default = null
}

variable "performance_insights_enabled" {
  type    = bool
  default = false
}

variable "performance_insights_kms_key_id" {
  type    = string
  default = null
}

variable "tags" {
  description = "Tags applied to all supported resources."
  type        = map(string)
  default     = {}
}
