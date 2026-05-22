resource "aws_security_group" "this" {
  count = var.create_security_group ? 1 : 0

  name        = var.security_group_name
  description = var.security_group_description
  vpc_id      = var.vpc_id
  tags        = merge(var.tags, var.security_group_tags)
}

resource "aws_vpc_security_group_ingress_rule" "this" {
  for_each = var.create_security_group ? var.security_group_ingress_rules : {}

  security_group_id            = aws_security_group.this[0].id
  description                  = each.value.description
  from_port                    = each.value.from_port
  to_port                      = each.value.to_port
  ip_protocol                  = each.value.ip_protocol
  cidr_ipv4                    = each.value.cidr_ipv4
  referenced_security_group_id = each.value.referenced_security_group_id
}

resource "aws_vpc_security_group_egress_rule" "this" {
  for_each = var.create_security_group ? var.security_group_egress_rules : {}

  security_group_id = aws_security_group.this[0].id
  description       = each.value.description
  from_port         = each.value.from_port
  to_port           = each.value.to_port
  ip_protocol       = each.value.ip_protocol
  cidr_ipv4         = each.value.cidr_ipv4
}

resource "aws_lb" "this" {
  name                             = var.name
  internal                         = var.internal
  load_balancer_type               = var.load_balancer_type
  security_groups                  = var.load_balancer_type == "application" ? concat(var.security_group_ids, var.create_security_group ? [aws_security_group.this[0].id] : []) : null
  subnets                          = var.subnet_ids
  enable_deletion_protection       = var.enable_deletion_protection
  drop_invalid_header_fields       = var.drop_invalid_header_fields
  enable_cross_zone_load_balancing = var.enable_cross_zone_load_balancing
  tags                             = var.tags

  dynamic "access_logs" {
    for_each = var.access_logs == null ? [] : [var.access_logs]

    content {
      bucket  = access_logs.value.bucket
      enabled = access_logs.value.enabled
      prefix  = access_logs.value.prefix
    }
  }
}

resource "aws_lb_target_group" "this" {
  for_each = var.target_groups

  name        = each.key
  port        = each.value.port
  protocol    = each.value.protocol
  target_type = each.value.target_type
  vpc_id      = var.vpc_id
  tags        = merge(var.tags, each.value.tags)

  health_check {
    enabled             = each.value.health_check.enabled
    healthy_threshold   = each.value.health_check.healthy_threshold
    interval            = each.value.health_check.interval
    matcher             = each.value.health_check.matcher
    path                = each.value.health_check.path
    port                = each.value.health_check.port
    protocol            = each.value.health_check.protocol
    timeout             = each.value.health_check.timeout
    unhealthy_threshold = each.value.health_check.unhealthy_threshold
  }
}

resource "aws_lb_listener" "this" {
  for_each = var.listeners

  load_balancer_arn = aws_lb.this.arn
  port              = each.value.port
  protocol          = each.value.protocol
  certificate_arn   = each.value.certificate_arn
  ssl_policy        = each.value.ssl_policy

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.this[each.value.target_group_key].arn
  }
}
