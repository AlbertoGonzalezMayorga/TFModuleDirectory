output "buckets" {
  description = "S3 buckets keyed by bucket name."
  value = {
    for name, bucket in aws_s3_bucket.this : name => {
      arn    = bucket.arn
      bucket = bucket.bucket
      id     = bucket.id
    }
  }
}
