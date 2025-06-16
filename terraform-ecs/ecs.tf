module "cluster" {
  source  = "terraform-aws-modules/ecs/aws//modules/cluster"
  version = "5.12.1"

  cluster_name = var.ecs_cluster_name

  create_cloudwatch_log_group = false

  tags = var.tags
}

module "ecs_service" {
  source  = "terraform-aws-modules/ecs/aws//modules/service"
  version = "5.12.1"

  name        = var.ecs_service_name
  cluster_arn = module.cluster.arn

  cpu                = 1024
  memory             = 4096
  enable_autoscaling = false

  container_definitions = {

    django = {
      cpu       = 512
      memory    = 1024
      essential = true
      image     = "${module.sample_django_repository.repository_url}:${var.application_version}"
      port_mappings = [
        {
          name          = "django"
          containerPort = 8000
          hostPort      = 8000
          protocol      = "tcp"

        }
      ]
      # Needed to create a temporary directory for gunicorn
      readonly_root_filesystem = false

      environment = [
        {
          name : "DEBUG",
          value : "True"
        },
        {
          name : "DJANGO_ALLOWED_HOSTS",
          value : "*"
        }
      ]
      secrets = [
        {
          name : "DATABASE_URL",
          valueFrom : aws_ssm_parameter.django_rds_creds.arn
        }
      ]

      dependencies = [{
        containerName = "django_init"
        condition     = "SUCCESS"
      }]
      enable_cloudwatch_logging = true
    },
    django_init = {
      cpu       = 128
      memory    = 128
      essential = false
      image     = "${module.sample_django_repository.repository_url}:${var.application_version}"
      command   = ["sh", "-c", "python manage.py migrate"]
      secrets = [
        {
          name : "DATABASE_URL",
          valueFrom : aws_ssm_parameter.django_rds_creds.arn
        }
      ]
      enable_cloudwatch_logging = true
    }
  }

  load_balancer = {
    service = {
      target_group_arn = module.alb.target_groups["django_ecs"].arn
      container_name   = "django"
      container_port   = 8000
    }
  }
  subnet_ids = module.vpc.private_subnets
  security_group_rules = {
    alb_ingress_3000 = {
      type                     = "ingress"
      from_port                = 8000
      to_port                  = 8000
      protocol                 = "tcp"
      description              = "Service port"
      source_security_group_id = module.alb.security_group_id
    }
    egress_all = {
      type        = "egress"
      from_port   = 0
      to_port     = 0
      protocol    = "-1"
      cidr_blocks = ["0.0.0.0/0"]
    }
  }
  tags = var.tags
}
