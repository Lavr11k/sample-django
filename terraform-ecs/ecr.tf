data "aws_caller_identity" "current" {}

module "sample_django_repository" {
  source  = "terraform-aws-modules/ecr/aws"
  version = "2.4.0"

  repository_name = var.ecr_repository_name

  repository_image_tag_mutability = "MUTABLE"
  repository_image_scan_on_push   = false

  create_lifecycle_policy           = false
  repository_read_write_access_arns = [data.aws_caller_identity.current.arn]

  tags = var.tags
}
