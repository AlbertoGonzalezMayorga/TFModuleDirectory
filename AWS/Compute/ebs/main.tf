resource "aws_elastic_beanstalk_application" "this" {
  name        = var.application_name
  description = var.application_description

  dynamic "appversion_lifecycle" {
    for_each = var.appversion_lifecycle == null ? [] : [var.appversion_lifecycle]

    content {
      service_role          = appversion_lifecycle.value.service_role
      max_count             = appversion_lifecycle.value.max_count
      delete_source_from_s3 = appversion_lifecycle.value.delete_source_from_s3
    }
  }

  tags = var.tags
}

resource "aws_elastic_beanstalk_environment" "this" {
  name                = var.environment_name
  application         = aws_elastic_beanstalk_application.this.name
  solution_stack_name = var.solution_stack_name
  platform_arn        = var.platform_arn
  tier                = var.tier
  tags                = var.tags

  dynamic "setting" {
    for_each = var.settings

    content {
      namespace = setting.value.namespace
      name      = setting.value.name
      value     = setting.value.value
      resource  = setting.value.resource
    }
  }
}
