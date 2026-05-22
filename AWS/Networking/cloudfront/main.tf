resource "aws_cloudfront_origin_access_control" "this" {
  for_each = { for name, origin in var.origins : name => origin if origin.create_origin_access_control }

  name                              = each.value.origin_access_control.name
  description                       = each.value.origin_access_control.description
  origin_access_control_origin_type = each.value.origin_access_control.origin_type
  signing_behavior                  = each.value.origin_access_control.signing_behavior
  signing_protocol                  = each.value.origin_access_control.signing_protocol
}

resource "aws_cloudfront_distribution" "this" {
  enabled             = var.enabled
  aliases             = var.aliases
  comment             = var.comment
  default_root_object = var.default_root_object
  http_version        = var.http_version
  is_ipv6_enabled     = var.is_ipv6_enabled
  price_class         = var.price_class
  web_acl_id          = var.web_acl_id
  tags                = var.tags

  dynamic "origin" {
    for_each = var.origins

    content {
      domain_name              = origin.value.domain_name
      origin_id                = origin.key
      origin_path              = origin.value.origin_path
      origin_access_control_id = origin.value.create_origin_access_control ? aws_cloudfront_origin_access_control.this[origin.key].id : origin.value.origin_access_control_id

      dynamic "custom_origin_config" {
        for_each = origin.value.custom_origin_config == null ? [] : [origin.value.custom_origin_config]

        content {
          http_port                = custom_origin_config.value.http_port
          https_port               = custom_origin_config.value.https_port
          origin_keepalive_timeout = custom_origin_config.value.origin_keepalive_timeout
          origin_protocol_policy   = custom_origin_config.value.origin_protocol_policy
          origin_read_timeout      = custom_origin_config.value.origin_read_timeout
          origin_ssl_protocols     = custom_origin_config.value.origin_ssl_protocols
        }
      }
    }
  }

  default_cache_behavior {
    allowed_methods            = var.default_cache_behavior.allowed_methods
    cached_methods             = var.default_cache_behavior.cached_methods
    compress                   = var.default_cache_behavior.compress
    target_origin_id           = var.default_cache_behavior.target_origin_id
    viewer_protocol_policy     = var.default_cache_behavior.viewer_protocol_policy
    cache_policy_id            = var.default_cache_behavior.cache_policy_id
    origin_request_policy_id   = var.default_cache_behavior.origin_request_policy_id
    response_headers_policy_id = var.default_cache_behavior.response_headers_policy_id
  }

  dynamic "ordered_cache_behavior" {
    for_each = var.ordered_cache_behaviors

    content {
      path_pattern               = ordered_cache_behavior.value.path_pattern
      allowed_methods            = ordered_cache_behavior.value.allowed_methods
      cached_methods             = ordered_cache_behavior.value.cached_methods
      compress                   = ordered_cache_behavior.value.compress
      target_origin_id           = ordered_cache_behavior.value.target_origin_id
      viewer_protocol_policy     = ordered_cache_behavior.value.viewer_protocol_policy
      cache_policy_id            = ordered_cache_behavior.value.cache_policy_id
      origin_request_policy_id   = ordered_cache_behavior.value.origin_request_policy_id
      response_headers_policy_id = ordered_cache_behavior.value.response_headers_policy_id
    }
  }

  restrictions {
    geo_restriction {
      restriction_type = var.geo_restriction.restriction_type
      locations        = var.geo_restriction.locations
    }
  }

  viewer_certificate {
    acm_certificate_arn            = var.viewer_certificate.acm_certificate_arn
    cloudfront_default_certificate = var.viewer_certificate.acm_certificate_arn == null
    minimum_protocol_version       = var.viewer_certificate.minimum_protocol_version
    ssl_support_method             = var.viewer_certificate.acm_certificate_arn == null ? null : var.viewer_certificate.ssl_support_method
  }

  dynamic "logging_config" {
    for_each = var.logging_config == null ? [] : [var.logging_config]

    content {
      bucket          = logging_config.value.bucket
      include_cookies = logging_config.value.include_cookies
      prefix          = logging_config.value.prefix
    }
  }
}
