output "load_balancer" {
  description = "Load balancer attributes."
  value = {
    arn      = aws_lb.this.arn
    dns_name = aws_lb.this.dns_name
    id       = aws_lb.this.id
    zone_id  = aws_lb.this.zone_id
  }
}

output "target_groups" {
  description = "Target groups keyed by name."
  value = {
    for name, tg in aws_lb_target_group.this : name => {
      arn  = tg.arn
      name = tg.name
    }
  }
}
