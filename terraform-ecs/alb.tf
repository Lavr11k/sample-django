module "alb" {
  source  = "terraform-aws-modules/alb/aws"
  version = "9.16.0"

  name                       = var.alb_name
  vpc_id                     = module.vpc.vpc_id
  subnets                    = module.vpc.public_subnets
  enable_deletion_protection = false

  security_group_ingress_rules = {
    all_http = {
      from_port   = 80
      to_port     = 80
      ip_protocol = "tcp"
      description = "HTTP web traffic"
      cidr_ipv4   = "0.0.0.0/0"
    }
  }

  security_group_egress_rules = {
    all = {
      ip_protocol = "-1"
      cidr_ipv4   = "0.0.0.0/0"
    }
  }

  listeners = {
    django_http = {
      port     = 80
      protocol = "HTTP"

      forward = {
        target_group_key = "django_ecs"
      }
    }

  }

  target_groups = {

    django_ecs = {
      backend_protocol     = "HTTP"
      backend_port         = 8000
      target_type          = "ip"
      deregistration_delay = 5

      health_check = {
        enabled             = true
        healthy_threshold   = 5
        interval            = 30
        matcher             = "200"
        path                = "/"
        port                = 8000
        protocol            = "HTTP"
        timeout             = 5
        unhealthy_threshold = 2
      }

      create_attachment = false
    }
  }
  tags = var.tags
}
