output "db_instance" {
  description = "RDS DB instance attributes."
  value = {
    address  = aws_db_instance.this.address
    arn      = aws_db_instance.this.arn
    endpoint = aws_db_instance.this.endpoint
    id       = aws_db_instance.this.id
    port     = aws_db_instance.this.port
  }
}
