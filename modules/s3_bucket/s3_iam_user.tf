#criar o grupo
resource "aws_iam_group" "group_s3_bucket" {
  name = "${var.bucket_name}-group"
}

#user bucket
resource "aws_iam_user" "user_s3_bucket" {
  name = "${var.bucket_name}-user"
  path = "/"
  tags = {
    name = "User for ${var.bucket_name}"
    repo = "${var.s3_vars.repo}"
  }
}

#atachar a policy no grupo
resource "aws_iam_group_policy_attachment" "bucket_group_attach" {
  group      = aws_iam_group.group_s3_bucket.name
  policy_arn = aws_iam_policy.iam_s3_policy.arn
}

#add user bucket no grupo
resource "aws_iam_user_group_membership" "bucket_s3_group_membership" {
  user = aws_iam_user.user_s3_bucket.name
  groups = [
    aws_iam_group.group_s3_bucket.name
  ]
}