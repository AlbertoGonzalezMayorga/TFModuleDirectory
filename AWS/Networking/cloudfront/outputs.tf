output "distribution" {
  description = "CloudFront distribution attributes."
  value = {
    arn            = aws_cloudfront_distribution.this.arn
    domain_name    = aws_cloudfront_distribution.this.domain_name
    hosted_zone_id = aws_cloudfront_distribution.this.hosted_zone_id
    id             = aws_cloudfront_distribution.this.id
  }
}
