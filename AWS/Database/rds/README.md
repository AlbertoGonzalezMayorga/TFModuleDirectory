# AWS RDS Terraform Module

Modulo generico para crear una instancia RDS. Puede crear subnet group, security group y parameter group, o usar recursos existentes.

## Que Crea

- `aws_db_instance`
- `aws_db_subnet_group`, opcional
- `aws_security_group`, opcional
- `aws_db_parameter_group`, opcional

## Ejemplo PostgreSQL Con Password Gestionada

```hcl
module "rds" {
  source = "./modules/AWS/Database/rds"

  identifier     = "platform-dev-postgres"
  engine         = "postgres"
  engine_version = "16.8"
  instance_class = "db.t4g.micro"

  subnet_ids = ["subnet-private-a", "subnet-private-b"]

  create_security_group = true
  vpc_id                 = "vpc-0123456789abcdef0"
  security_group_ingress_rules = {
    app = {
      from_port                    = 5432
      to_port                      = 5432
      ip_protocol                  = "tcp"
      referenced_security_group_id = "sg-app"
    }
  }

  username                    = "app"
  manage_master_user_password = true
  storage_encrypted           = true
}
```

## Usar Recursos Existentes

```hcl
module "rds" {
  source = "./modules/AWS/Database/rds"

  identifier             = "platform-prod-db"
  create_db_subnet_group = false
  db_subnet_group_name   = "existing-db-subnet-group"
  vpc_security_group_ids = ["sg-existing"]
}
```

## Inputs Principales

- `identifier`: identificador de la instancia.
- `engine`, `engine_version`, `instance_class`.
- `allocated_storage`, `storage_type`, `storage_encrypted`, `kms_key_id`.
- `manage_master_user_password`: usa Secrets Manager para password master.
- `create_db_subnet_group`, `subnet_ids`, `db_subnet_group_name`.
- `create_security_group`, `security_group_ingress_rules`, `vpc_security_group_ids`.
- `create_parameter_group`, `parameter_group_family`, `parameters`.
- `backup_retention_period`, `multi_az`, `deletion_protection`.

## Outputs

- `db_instance`: `address`, `arn`, `endpoint`, `id`, `port`.

## Notas

Si `manage_master_user_password = false`, debes pasar `password`. Mantén ese valor como sensitive en el root module.
