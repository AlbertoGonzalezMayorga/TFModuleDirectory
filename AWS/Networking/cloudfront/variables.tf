variable "enabled" {
  type    = bool
  default = true
}

variable "aliases" {
  type    = list(string)
  default = []
}

variable "comment" {
  type    = string
  default = null
}

variable "default_root_object" {
  type    = string
  default = null
}

variable "http_version" {
  type    = string
  default = "http2"
}

variable "is_ipv6_enabled" {
  type    = bool
  default = true
}

variable "price_class" {
  type    = string
  default = "PriceClass_100"
}

variable "web_acl_id" {
  type    = string
  default = null
}

variable "origins" {
  description = "CloudFront origins keyed by origin ID."
  type = map(object({
    domain_name                  = string
    origin_path                  = optional(string, null)
    origin_access_control_id     = optional(string, null)
    create_origin_access_control = optional(bool, false)
    origin_access_control = optional(object({
      name             = string
      description      = optional(string, null)
      origin_type      = optional(string, "s3")
      signing_behavior = optional(string, "always")
      signing_protocol = optional(string, "sigv4")
    }), null)
    custom_origin_config = optional(object({
      http_port                = optional(number, 80)
      https_port               = optional(number, 443)
      origin_keepalive_timeout = optional(number, 5)
      origin_protocol_policy   = optional(string, "https-only")
      origin_read_timeout      = optional(number, 30)
      origin_ssl_protocols     = optional(list(string), ["TLSv1.2"])
    }), null)
  }))
}

variable "default_cache_behavior" {
  description = "Default cache behavior."
  type = object({
    target_origin_id           = string
    allowed_methods            = optional(list(string), ["GET", "HEAD"])
    cached_methods             = optional(list(string), ["GET", "HEAD"])
    compress                   = optional(bool, true)
    viewer_protocol_policy     = optional(string, "redirect-to-https")
    cache_policy_id            = optional(string, null)
    origin_request_policy_id   = optional(string, null)
    response_headers_policy_id = optional(string, null)
  })
}

variable "ordered_cache_behaviors" {
  description = "Ordered cache behaviors."
  type = list(object({
    path_pattern               = string
    target_origin_id           = string
    allowed_methods            = optional(list(string), ["GET", "HEAD"])
    cached_methods             = optional(list(string), ["GET", "HEAD"])
    compress                   = optional(bool, true)
    viewer_protocol_policy     = optional(string, "redirect-to-https")
    cache_policy_id            = optional(string, null)
    origin_request_policy_id   = optional(string, null)
    response_headers_policy_id = optional(string, null)
  }))
  default = []
}

variable "geo_restriction" {
  description = "Geo restriction configuration."
  type = object({
    restriction_type = optional(string, "none")
    locations        = optional(list(string), [])
  })
  default = {}
}

variable "viewer_certificate" {
  description = "Viewer certificate configuration."
  type = object({
    acm_certificate_arn      = optional(string, null)
    minimum_protocol_version = optional(string, "TLSv1.2_2021")
    ssl_support_method       = optional(string, "sni-only")
  })
  default = {}
}

variable "logging_config" {
  description = "Logging configuration."
  type = object({
    bucket          = string
    include_cookies = optional(bool, false)
    prefix          = optional(string, "")
  })
  default = null
}

variable "tags" {
  description = "Tags applied to the distribution."
  type        = map(string)
  default     = {}
}
