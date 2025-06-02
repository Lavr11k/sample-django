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
    django = {
      port     = 80
      protocol = "HTTP"

      forward = {
        target_group_key = "django"
      }
    }
  }

  target_groups = {
    django = {
      protocol             = "HTTP"
      port                 = 80
      target_type          = "instance"
      target_id            = module.ec2_webserver_instance.id
      deregistration_delay = 5

      health_check = {
        enabled             = true
        healthy_threshold   = 5
        interval            = 30
        matcher             = "200"
        path                = "/"
        port                = "80"
        protocol            = "HTTP"
        timeout             = 5
        unhealthy_threshold = 2
      }

    }
  }


  tags = var.tags
}
