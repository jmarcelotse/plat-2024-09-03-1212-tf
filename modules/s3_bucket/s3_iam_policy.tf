###POLICY FOR S3###
resource "aws_iam_policy" "iam_s3_policy" {
  name        = "iam-${var.bucket_name}-policy"
  path        = "/"
  description = "Enable squad to access buckets"

  tags = {
    name = "iam-${var.bucket_name}-policy"
    repo = "${var.s3_vars.repo}"
  }

  policy = jsonencode({
    Version   = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
         "s3:PutObject",
                "s3:GetObject",
                "s3:ListBucket",
                "s3:DeleteObject",
                "s3:GetBucketAcl"
        ],                           
        Resource = [

          "arn:aws:s3:::${aws_s3_bucket.bucket.id}",
          "arn:aws:s3:::${aws_s3_bucket.bucket.id}/*"
          # Linha acima permite listar o recurso usando no final da linha o "/*", padrão AWS
        ]
      } 
    ]  
  })
}
