variable "application_version" {
  description = "Application version (image tag) to deploy"
  type        = string
}

############################################################
#                           VPC                            #
############################################################

variable "vpc_name" {
  description = "Name of the VPC"
  type        = string
}

variable "vpc_cidr_block" {
  description = "VPC CIDR block to use"
  type        = string
}

variable "vpc_private_subnets_amount" {
  description = "Amount of private subnets to create in VPC"
  type        = number
  default     = 2
}

variable "vpc_public_subnets_amount" {
  description = "Amount of public subnets to create in VPC"
  type        = number
  default     = 2
}

variable "vpc_database_subnets_amount" {
  description = "Amount of database subnets to create in VPC"
  type        = number
  default     = 2
}

variable "vpc_tags" {
  description = "Additional tags for the VPC"
  type        = map(string)
  default     = {}
}

############################################################
#                            ALB                           #
############################################################

variable "alb_name" {
  description = "Name to be used on ALB"
  type        = string
}

############################################################
#                        PostgreSQL                        #
############################################################

variable "rds_identifier" {
  description = "RDS identifier to use"
  type        = string
}

variable "rds_instance_class" {
  description = "RDS instance class to use"
  type        = string
  default     = "db.t3.micro"
}

variable "rds_db_name" {
  description = "RDS database name to create"
  type        = string
  default     = "app"
}

variable "rds_db_master_username" {
  description = "RDS database master name to use"
  type        = string
  default     = "django"
}

variable "rds_db_master_password" {
  description = "RDS database master password to use. Generated if not provided"
  type        = string
  default     = ""
}

variable "rds_sg_name" {
  description = "RDS SecurityGroup name to create"
  type        = string
  default     = "django-postgres-sg"
}

############################################################
#                            ECS                           #
############################################################

variable "ecs_cluster_name" {
  description = "ECS cluster name to use"
  type        = string
}

variable "ecs_service_name" {
  description = "ECS service name to use"
  type        = string
}

############################################################
#                            ECR                           #
############################################################

variable "ecr_repository_name" {
  description = "ECR repository name to use"
  type        = string
}

############################################################
#                          Common                          #
############################################################

variable "tags" {
  description = "A map of tags to add to all resources"
  type        = map(string)
  default = {
    owner      = "Anastasiia Lavrynovych"
    managed_by = "terraform"
  }
}

variable "region" {
  description = "A region to use"
  type        = string
  default     = "eu-central-1"
}
