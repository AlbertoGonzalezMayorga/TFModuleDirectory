resource "aws_db_subnet_group" "this" {
  count = var.create_db_subnet_group ? 1 : 0

  name        = var.db_subnet_group_name
  description = var.db_subnet_group_description
  subnet_ids  = var.subnet_ids
  tags        = var.tags
}

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

resource "aws_db_parameter_group" "this" {
  count = var.create_parameter_group ? 1 : 0

  name        = var.parameter_group_name
  family      = var.parameter_group_family
  description = var.parameter_group_description
  tags        = var.tags

  dynamic "parameter" {
    for_each = var.parameters

    content {
      name         = parameter.value.name
      value        = parameter.value.value
      apply_method = parameter.value.apply_method
    }
  }
}

resource "aws_db_instance" "this" {
  identifier = var.identifier

  allocated_storage                   = var.allocated_storage
  allow_major_version_upgrade         = var.allow_major_version_upgrade
  auto_minor_version_upgrade          = var.auto_minor_version_upgrade
  backup_retention_period             = var.backup_retention_period
  backup_window                       = var.backup_window
  copy_tags_to_snapshot               = var.copy_tags_to_snapshot
  db_name                             = var.db_name
  db_subnet_group_name                = var.create_db_subnet_group ? aws_db_subnet_group.this[0].name : var.db_subnet_group_name
  deletion_protection                 = var.deletion_protection
  enabled_cloudwatch_logs_exports     = var.enabled_cloudwatch_logs_exports
  engine                              = var.engine
  engine_version                      = var.engine_version
  final_snapshot_identifier           = var.final_snapshot_identifier
  iam_database_authentication_enabled = var.iam_database_authentication_enabled
  instance_class                      = var.instance_class
  kms_key_id                          = var.kms_key_id
  maintenance_window                  = var.maintenance_window
  manage_master_user_password         = var.manage_master_user_password
  monitoring_interval                 = var.monitoring_interval
  monitoring_role_arn                 = var.monitoring_role_arn
  multi_az                            = var.multi_az
  parameter_group_name                = var.create_parameter_group ? aws_db_parameter_group.this[0].name : var.parameter_group_name
  password                            = var.manage_master_user_password ? null : var.password
  performance_insights_enabled        = var.performance_insights_enabled
  performance_insights_kms_key_id     = var.performance_insights_kms_key_id
  publicly_accessible                 = var.publicly_accessible
  skip_final_snapshot                 = var.skip_final_snapshot
  storage_encrypted                   = var.storage_encrypted
  storage_type                        = var.storage_type
  username                            = var.username
  vpc_security_group_ids              = concat(var.vpc_security_group_ids, var.create_security_group ? [aws_security_group.this[0].id] : [])
  tags                                = var.tags
}
