data "aws_iam_policy_document" "bastion_role" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }
}

resource "aws_iam_role" "bastion_role" {
  name               = "bastion_role"
  assume_role_policy = data.aws_iam_policy_document.bastion_role.json
}

resource "aws_iam_role_policy_attachment" "ssm_core" {
  role       = aws_iam_role.bastion_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource "aws_iam_role_policy_attachment" "ssm_parameter_read" {
  role       = aws_iam_role.bastion_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMReadOnlyAccess"
}

data "aws_iam_policy_document" "s3_read_access" {
  statement {
    actions = [
      "s3:ListBucket",
      "s3:GetObject",
      "s3:GetObjectVersion"
    ]
    resources = [
      "arn:aws:s3:::itsyndicate-course-bucket",
      "arn:aws:s3:::itsyndicate-course-bucket/*"
    ]
  }
}

resource "aws_iam_policy" "s3_read_policy" {
  name        = "BastionS3ReadAccess"
  description = "Allow read access to specific S3 bucket"
  policy      = data.aws_iam_policy_document.s3_read_access.json
}

resource "aws_iam_role_policy_attachment" "s3_read" {
  role       = aws_iam_role.bastion_role.name
  policy_arn = aws_iam_policy.s3_read_policy.arn
}

resource "aws_iam_instance_profile" "bastion_profile" {
  name = "bastion-profile"
  role = aws_iam_role.bastion_role.name
}
