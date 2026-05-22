output "application" {
  description = "Elastic Beanstalk application attributes."
  value = {
    arn  = aws_elastic_beanstalk_application.this.arn
    name = aws_elastic_beanstalk_application.this.name
  }
}

output "environment" {
  description = "Elastic Beanstalk environment attributes."
  value = {
    arn      = aws_elastic_beanstalk_environment.this.arn
    endpoint = aws_elastic_beanstalk_environment.this.endpoint_url
    id       = aws_elastic_beanstalk_environment.this.id
    name     = aws_elastic_beanstalk_environment.this.name
  }
}
