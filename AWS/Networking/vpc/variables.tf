###############
## Networking ##
###############

variable "create_vpc" {
  description = "Whether to create a new VPC. If false, vpc_id must be provided."
  type        = bool
  default     = true

  validation {
    condition = (
      (var.create_vpc && var.vpc_id == null) ||
      (!var.create_vpc && var.vpc_id != null && trimspace(var.vpc_id) != "")
    )

    error_message = "create_vpc and vpc_id are mutually exclusive: if create_vpc is true, vpc_id must be null; if create_vpc is false, vpc_id must be provided."
  }
}

variable "vpc_id" {
  description = "ID of an existing VPC to use when create_vpc is false."
  type        = string
  default     = null
}

variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  type        = string
}

variable "create_flow_log" {
  description = "Whether to create a VPC Flow Log"
  type        = bool
  default     = false
}

variable "logs_bucket_arn" {
  description = "ARN of the S3 bucket for VPC Flow Logs. Required only when log_destination_type is s3."
  type        = string
  default     = null
}

variable "log_destination_type" {
  description = "The type of destination for the flow log data. Valid values are cloud-watch-logs or s3."
  type        = string
  default     = "cloud-watch-logs"

  validation {
    condition = contains([
      "cloud-watch-logs",
      "s3"
    ], var.log_destination_type)

    error_message = "log_destination_type must be either 'cloud-watch-logs' or 's3'."
  }

  validation {
    condition = (
      (
        var.log_destination_type == "s3" &&
        var.logs_bucket_arn != null &&
        trimspace(var.logs_bucket_arn) != ""
      ) ||
      (
        var.log_destination_type == "cloud-watch-logs" &&
        (
          var.logs_bucket_arn == null ||
          trimspace(var.logs_bucket_arn) == ""
        )
      )
    )

    error_message = "logs_bucket_arn and log_destination_type are mutually dependent: if log_destination_type is 's3', logs_bucket_arn must be provided; if log_destination_type is 'cloud-watch-logs', logs_bucket_arn must be null."
  }
}

variable "traffic_type" {
  description = "The type of traffic to log. Valid values are 'ACCEPT', 'REJECT', or 'ALL'."
  type        = string
  default     = "ALL"
}

###############
## General / Project / Environment ##
###############

variable "environment" {
  description = "Environment name"
  type        = string
  default     = null
}

variable "project_name" {
  description = "Name of the project"
  type        = string
  default     = null
}

variable "region" {
  description = "AWS Region"
  type        = string
}

variable "tags" {
  description = "Tags to apply to resources"
  type        = map(string)
  default     = {}
}
