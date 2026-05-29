###############
## Networking ##
###############

variable "name" {
  description = "Name prefix used for VPC resources."
  type        = string
  default     = "vpc"
}

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
  description = "CIDR block for the VPC."
  type        = string
}

variable "enable_dns_support" {
  description = "Whether DNS support is enabled for the VPC."
  type        = bool
  default     = true
}

variable "enable_dns_hostnames" {
  description = "Whether DNS hostnames are enabled for the VPC."
  type        = bool
  default     = true
}

variable "availability_zones" {
  description = "Availability zones to use. If empty, the first az_count available zones in the region are used."
  type        = list(string)
  default     = []
}

variable "exclude_availability_zone_names" {
  description = "Availability zone names to exclude when availability_zones is empty."
  type        = list(string)
  default     = []
}

variable "az_count" {
  description = "Number of availability zones to use when availability_zones is empty."
  type        = number
  default     = 3

  validation {
    condition     = var.az_count > 0
    error_message = "az_count must be greater than zero."
  }
}

variable "subnet_newbits" {
  description = "Additional subnet bits used when subnet CIDRs are generated automatically."
  type        = number
  default     = 4

  validation {
    condition     = var.subnet_newbits >= 0
    error_message = "subnet_newbits must be zero or greater."
  }
}

variable "public_subnet_count" {
  description = "Number of public subnets to create when public_subnet_cidrs is empty."
  type        = number
  default     = 3
}

variable "private_subnet_count" {
  description = "Number of private subnets to create when private_subnet_cidrs is empty."
  type        = number
  default     = 3
}

variable "isolated_subnet_count" {
  description = "Number of isolated subnets to create when isolated_subnet_cidrs is empty."
  type        = number
  default     = 0
}

variable "public_subnet_cidrs" {
  description = "Explicit CIDR blocks for public subnets. Overrides public_subnet_count when non-empty."
  type        = list(string)
  default     = []
}

variable "private_subnet_cidrs" {
  description = "Explicit CIDR blocks for private subnets. Overrides private_subnet_count when non-empty."
  type        = list(string)
  default     = []
}

variable "isolated_subnet_cidrs" {
  description = "Explicit CIDR blocks for isolated subnets. Overrides isolated_subnet_count when non-empty."
  type        = list(string)
  default     = []
}

variable "public_subnets_map_public_ip_on_launch" {
  description = "Whether public subnets map public IPv4 addresses on launch."
  type        = bool
  default     = true
}

variable "create_internet_gateway" {
  description = "Whether to create an Internet Gateway for public subnets."
  type        = bool
  default     = true
}

variable "enable_nat_gateway" {
  description = "Whether to create NAT Gateway resources for private subnets."
  type        = bool
  default     = true
}

variable "single_nat_gateway" {
  description = "Whether to create a single shared NAT Gateway. If false, one NAT Gateway is created per public/private subnet pair."
  type        = bool
  default     = true
}

###############
## Flow Logs ##
###############

variable "create_flow_log" {
  description = "Whether to create a VPC Flow Log."
  type        = bool
  default     = false
}

variable "logs_bucket_arn" {
  description = "ARN of the S3 bucket for VPC Flow Logs. Required only when log_destination_type is s3."
  type        = string
  default     = null
}

variable "log_destination_type" {
  description = "The type of destination for flow log data. Valid values are cloud-watch-logs or s3."
  type        = string
  default     = "cloud-watch-logs"

  validation {
    condition     = contains(["cloud-watch-logs", "s3"], var.log_destination_type)
    error_message = "log_destination_type must be either 'cloud-watch-logs' or 's3'."
  }

  validation {
    condition = (
      !var.create_flow_log ||
      (
        var.log_destination_type == "s3" &&
        var.logs_bucket_arn != null &&
        trimspace(var.logs_bucket_arn) != ""
      ) ||
      (
        var.log_destination_type == "cloud-watch-logs" &&
        var.flow_log_cloudwatch_iam_role_arn != null &&
        trimspace(var.flow_log_cloudwatch_iam_role_arn) != ""
      )
    )

    error_message = "When create_flow_log is true, provide logs_bucket_arn for s3 or flow_log_cloudwatch_iam_role_arn for cloud-watch-logs."
  }
}

variable "traffic_type" {
  description = "The type of traffic to log. Valid values are ACCEPT, REJECT, or ALL."
  type        = string
  default     = "ALL"

  validation {
    condition     = contains(["ACCEPT", "REJECT", "ALL"], var.traffic_type)
    error_message = "traffic_type must be ACCEPT, REJECT, or ALL."
  }
}

variable "flow_log_cloudwatch_iam_role_arn" {
  description = "IAM role ARN used by VPC Flow Logs to write to CloudWatch Logs."
  type        = string
  default     = null
}

variable "flow_log_cloudwatch_log_group_name" {
  description = "CloudWatch Log Group name for VPC Flow Logs. Defaults to /aws/vpc/flow-logs/<vpc-id>."
  type        = string
  default     = null
}

variable "flow_log_cloudwatch_log_group_retention_in_days" {
  description = "Retention in days for the VPC Flow Logs CloudWatch Log Group."
  type        = number
  default     = 30
}

###############
## Tags ##
###############

variable "tags" {
  description = "Tags applied to all supported resources."
  type        = map(string)
  default     = {}
}

variable "vpc_tags" {
  description = "Additional tags applied to the VPC."
  type        = map(string)
  default     = {}
}

variable "public_subnet_tags" {
  description = "Additional tags applied to public subnets."
  type        = map(string)
  default     = {}
}

variable "private_subnet_tags" {
  description = "Additional tags applied to private subnets."
  type        = map(string)
  default     = {}
}

variable "isolated_subnet_tags" {
  description = "Additional tags applied to isolated subnets."
  type        = map(string)
  default     = {}
}

variable "internet_gateway_tags" {
  description = "Additional tags applied to the Internet Gateway."
  type        = map(string)
  default     = {}
}

variable "nat_gateway_tags" {
  description = "Additional tags applied to NAT Gateway resources."
  type        = map(string)
  default     = {}
}

variable "public_route_table_tags" {
  description = "Additional tags applied to the public route table."
  type        = map(string)
  default     = {}
}

variable "private_route_table_tags" {
  description = "Additional tags applied to private route tables."
  type        = map(string)
  default     = {}
}

variable "isolated_route_table_tags" {
  description = "Additional tags applied to isolated route tables."
  type        = map(string)
  default     = {}
}
