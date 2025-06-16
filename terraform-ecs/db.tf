locals {
  rds_db_master_password = var.rds_db_master_password == "" ? random_password.rds_password[0].result : var.rds_db_master_password
}

resource "random_password" "rds_password" {
  count = var.rds_db_master_password == "" ? 1 : 0

  length           = 16
  special          = true
  override_special = "!#$%&*()-_=+[]{}?"
}

resource "aws_ssm_parameter" "django_rds_creds" {
  name        = "/django/rds/connectionString"
  description = "Connection string for sample Django application"
  type        = "SecureString"
  value       = "postgres://${var.rds_db_master_username}:${local.rds_db_master_password}@${module.rds.db_instance_address}:5432/${var.rds_db_name}"
}

module "rds" {
  source  = "terraform-aws-modules/rds/aws"
  version = "6.12.0"

  identifier               = var.rds_identifier
  engine                   = "postgres"
  engine_version           = "17"
  engine_lifecycle_support = "open-source-rds-extended-support-disabled"
  family                   = "postgres17"
  major_engine_version     = "17"
  instance_class           = var.rds_instance_class

  allocated_storage = 20

  db_name                     = var.rds_db_name
  username                    = var.rds_db_master_username
  password                    = local.rds_db_master_password
  port                        = 5432
  manage_master_user_password = false

  db_subnet_group_name   = module.vpc.database_subnet_group
  vpc_security_group_ids = [module.rds_security_group.security_group_id]

  skip_final_snapshot = true

  tags = var.tags
}

module "rds_security_group" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "5.3.0"

  name        = var.rds_sg_name
  description = "Django PostgreSQL security group"
  vpc_id      = module.vpc.vpc_id

  computed_ingress_with_source_security_group_id = [
    {
      rule                     = "postgresql-tcp"
      source_security_group_id = module.ecs_service.security_group_id
    }
  ]
  number_of_computed_ingress_with_source_security_group_id = 1

  tags = var.tags
}
