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

############################################################
#                      Security group                      #
############################################################

variable "web_server_sg_name" {
  description = "Name to be used on web server security group"
  type        = string
}
