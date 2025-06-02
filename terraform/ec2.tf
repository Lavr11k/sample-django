data "aws_ami" "ubuntu_2404" {
  owners = ["amazon"]

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd-gp3/ubuntu-noble-24.04-amd64-server-20250305"]
  }
}

module "bastion" {
  source  = "terraform-aws-modules/ec2-instance/aws"
  version = "5.8.0"

  name = "bastion"

  ami           = data.aws_ami.ubuntu_2404.id
  instance_type = "t2.micro"
  key_name      = "Key-eu-central-1"

  vpc_security_group_ids = [module.bastion_sg.security_group_id]
  subnet_id              = module.vpc.public_subnets[0]

  associate_public_ip_address = true
  iam_instance_profile        = aws_iam_instance_profile.bastion_profile.name

  user_data_base64 = base64encode(templatefile("./user-data/bastion.sh.tftpl", {
    database_private_ip = module.ec2_db_instance.private_ip,
    app_private_ips = [
      module.ec2_webserver_instance.private_ip
    ]
  }))
}

module "ec2_webserver_instance" {
  source  = "terraform-aws-modules/ec2-instance/aws"
  version = "5.8.0"

  name = "Django-application"

  ami           = data.aws_ami.ubuntu_2404.id
  instance_type = "t2.micro"
  key_name      = aws_key_pair.webserver-key.key_name

  vpc_security_group_ids = [module.web_server_sg.security_group_id]
  subnet_id              = module.vpc.private_subnets[0]
}

module "ec2_db_instance" {
  source  = "terraform-aws-modules/ec2-instance/aws"
  version = "5.8.0"

  name = "Django-database"

  ami           = data.aws_ami.ubuntu_2404.id
  instance_type = "t2.micro"
  key_name      = aws_key_pair.database-key.key_name

  vpc_security_group_ids = [module.db_sg.security_group_id]
  subnet_id              = module.vpc.private_subnets[0]
}

module "db_sg" {
  source  = "terraform-aws-modules/security-group/aws//modules/postgresql"
  version = "5.3.0"

  name   = "django-db-sg"
  vpc_id = module.vpc.vpc_id

  ingress_with_source_security_group_id = [
    {
      source_security_group_id = module.web_server_sg.security_group_id
      from_port                = 5432
      to_port                  = 5432
      protocol                 = "TCP"
    }
  ]

  computed_ingress_with_source_security_group_id = [
    {
      rule                     = "all-all"
      source_security_group_id = module.bastion_sg.security_group_id
    }
  ]
  number_of_computed_ingress_with_source_security_group_id = 1
}

module "web_server_sg" {
  source  = "terraform-aws-modules/security-group/aws//modules/http-80"
  version = "5.3.0"

  name   = var.web_server_sg_name
  vpc_id = module.vpc.vpc_id

  ingress_with_source_security_group_id = [
    {
      source_security_group_id = module.alb.security_group_id
      from_port                = 80
      to_port                  = 80
      protocol                 = "TCP"
    }
  ]

  computed_ingress_with_source_security_group_id = [
    {
      rule                     = "all-all"
      source_security_group_id = module.bastion_sg.security_group_id
    }
  ]
  number_of_computed_ingress_with_source_security_group_id = 1
}

module "bastion_sg" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "5.3.0"

  name   = "bastion-sg"
  vpc_id = module.vpc.vpc_id

  ingress_cidr_blocks = ["0.0.0.0/0"]
  ingress_rules       = ["ssh-tcp"]

  egress_cidr_blocks = ["0.0.0.0/0"]
  egress_rules       = ["all-all"]
}
