variable "application_name" {
  description = "Elastic Beanstalk application name."
  type        = string
}

variable "application_description" {
  description = "Elastic Beanstalk application description."
  type        = string
  default     = null
}

variable "environment_name" {
  description = "Elastic Beanstalk environment name."
  type        = string
}

variable "solution_stack_name" {
  description = "Elastic Beanstalk solution stack name."
  type        = string
  default     = null
}

variable "platform_arn" {
  description = "Elastic Beanstalk platform ARN."
  type        = string
  default     = null
}

variable "tier" {
  description = "Elastic Beanstalk tier."
  type        = string
  default     = "WebServer"
}

variable "appversion_lifecycle" {
  description = "Application version lifecycle configuration."
  type = object({
    service_role          = string
    max_count             = optional(number, 128)
    delete_source_from_s3 = optional(bool, true)
  })
  default = null
}

variable "settings" {
  description = "Elastic Beanstalk environment settings."
  type = list(object({
    namespace = string
    name      = string
    value     = string
    resource  = optional(string, null)
  }))
  default = []
}

variable "tags" {
  description = "Tags applied to all supported resources."
  type        = map(string)
  default     = {}
}
