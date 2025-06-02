resource "tls_private_key" "database-key" {
  algorithm = "RSA"
}

resource "tls_private_key" "app-key" {
  algorithm = "RSA"
}

resource "aws_key_pair" "database-key" {
  key_name   = "Django-Database-key"
  public_key = tls_private_key.database-key.public_key_openssh
}

resource "aws_key_pair" "webserver-key" {
  key_name   = "Django-Webserver-key"
  public_key = tls_private_key.app-key.public_key_openssh
}

resource "aws_ssm_parameter" "database_private_key" {
  name        = "/bastion/keys/database-key"
  description = "Private key for Django Database EC2 instance"
  type        = "SecureString"
  value       = tls_private_key.database-key.private_key_pem
}

resource "aws_ssm_parameter" "app_private_key" {
  name        = "/bastion/keys/app-key"
  description = "Private key for Django Webserver EC2 instance"
  type        = "SecureString"
  value       = tls_private_key.app-key.private_key_pem
}
