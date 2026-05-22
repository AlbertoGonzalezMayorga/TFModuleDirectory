# AWS Load Balancer Terraform Module

Modulo generico para crear un Application Load Balancer o Network Load Balancer con security group opcional, target groups, listeners y access logs opcionales.

## Que Crea

- `aws_lb`
- `aws_lb_target_group`, uno o varios
- `aws_lb_listener`, uno o varios
- `aws_security_group`, opcional
- reglas ingress/egress con recursos `aws_vpc_security_group_*_rule`

## Ejemplo HTTP Basico

```hcl
module "alb" {
  source = "./modules/AWS/Networking/alb"

  name       = "platform-dev-alb"
  vpc_id     = "vpc-0123456789abcdef0"
  subnet_ids = ["subnet-0123456789abcdef0", "subnet-0fedcba9876543210"]

  security_group_ingress_rules = {
    http = {
      from_port   = 80
      to_port     = 80
      ip_protocol = "tcp"
      cidr_ipv4   = "0.0.0.0/0"
    }
  }

  target_groups = {
    app = {
      port        = 80
      protocol    = "HTTP"
      target_type = "ip"
    }
  }

  listeners = {
    http = {
      port             = 80
      protocol         = "HTTP"
      target_group_key = "app"
    }
  }
}
```

## HTTPS

```hcl
listeners = {
  https = {
    port             = 443
    protocol         = "HTTPS"
    certificate_arn  = "arn:aws:acm:eu-west-1:123456789012:certificate/..."
    ssl_policy       = "ELBSecurityPolicy-TLS13-1-2-2021-06"
    target_group_key = "app"
  }
}
```

## Inputs Principales

- `name`: nombre del load balancer.
- `load_balancer_type`: `application` o `network`.
- `internal`: crea un LB interno si es `true`.
- `target_groups`: mapa de target groups.
- `listeners`: mapa de listeners.
- `create_security_group`: crea SG para ALB si aplica.
- `access_logs`: bucket y prefijo para access logs.

## Outputs

- `load_balancer`: `arn`, `dns_name`, `id`, `zone_id`.
- `target_groups`: ARNs y nombres por target group.
