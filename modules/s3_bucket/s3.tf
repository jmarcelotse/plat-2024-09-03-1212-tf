resource "aws_s3_bucket" "bucket" {
  bucket = var.bucket_name  #padrao prd-s3-alelo-nome -> ex: "${lower(var.environment)}-s3-alelo-backofficealelo-logistic-files"  
  tags = merge({
    info          = "Criado pela plataforma",
    Name = var.bucket_name
    },
    try(var.tags, {})
  )
}

#### CRIPTOGRAFIA DO BUCKET (ITEM OBRIGATORIO, EXIGIDO POR SI) ####
resource "aws_s3_bucket_server_side_encryption_configuration" "bucket" {
  bucket = aws_s3_bucket.bucket.id
  rule {
    bucket_key_enabled = false
    
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

### VERSIONAMENTO DE OBJETOS NO BUCKET ###
resource "aws_s3_bucket_versioning" "bucket" {
  bucket = aws_s3_bucket.bucket.id
  
  depends_on = [aws_s3_bucket_policy.bucket]
  
  versioning_configuration {
    status = "Enabled"
  }
}

##### REGRA DE LIFECYCLE (LIMPEZA AUTOMATICA DE OBJETOS) #####
## OBS.: caso os objetos do bucket não possam ser deletados este bloco pode ser excluido para que o lifecycle não seja criado
## Esta regra de Lifecycle esta fazendo a transição entre as classes e exclusão dos arquivos da seguinte maneira:

# Apos 90  dias da criação do objeto - STANDARD_IA
# Apos 180 dias da criação do objeto - GLACIER
# Apos 365 dias da criação do objeto - DELETAR O OBJETO

##### IMPORTANTE: ESTA REGRA ESTA FAZENDO ESTAS MOVIMENTAÇÕES EM VERSÕES ATUAIS E NÃO ATUAIS DOS OBJETOS ####
resource "aws_s3_bucket_lifecycle_configuration" "bucket" {
  bucket = aws_s3_bucket.bucket.id

  rule {
    id     = "Lifecycle"
    status = "Enabled"

    transition {
      days          = 90
      storage_class = "STANDARD_IA"
    }
    transition {
      days          = 180
      storage_class = "GLACIER"
    }
    expiration {
      days = 365
    }
    noncurrent_version_transition {
      noncurrent_days = 90
      storage_class   = "STANDARD_IA"
    }
    noncurrent_version_transition {
      noncurrent_days = 180
      storage_class   = "GLACIER"
    }
    noncurrent_version_expiration {
      noncurrent_days = 365
    }
  }
}

### POLITICA DE OWNER DOS OBJETOS DO BUCKET (EM CASOS ISOLADOS PODERÁ SER ALTERADA) ###
resource "aws_s3_bucket_ownership_controls" "bucket" {
  bucket = aws_s3_bucket.bucket.id
  rule {
    object_ownership = "BucketOwnerPreferred"
  }
}

### POLITICA DE CONTROLE DE ACESSO AO BUCKET ###
resource "aws_s3_bucket_acl" "bucket" {
  depends_on = [aws_s3_bucket_ownership_controls.bucket]
  
  bucket     = aws_s3_bucket.bucket.id
  acl        = "private"
}

### POLITICA DO BUCKET MINIMA EXIGIDA POR SI ###
# ESTA POLITICA FAZ O BLOQUEIO DE ACESSO VIA HTTP, PERMITINDO APENAS CHAMADAS HTTPS, É UMA DAS EXIGENCIAS DE SI E PRECISA ESTAR EM TODOS OS BUCKETS #
resource "aws_s3_bucket_policy" "bucket" {
  bucket = aws_s3_bucket.bucket.id
  depends_on = [aws_s3_bucket_acl.bucket]

  policy = jsonencode(
    {
      Version = "2012-10-17"
      Statement = [
        {
          Sid       = "AllowSSLRequestOnly"
          Effect    = "Deny"
          Action    = ["s3:*"]
          Principal = "*"
          Resource = [
            "arn:aws:s3:::${aws_s3_bucket.bucket.id}/*",
            "arn:aws:s3:::${aws_s3_bucket.bucket.id}"
          ]
          Condition = {
            Bool = {
              "aws:SecureTransport" = "false"
            }
          }
        }
      ]
    }
  )
}

# NOTIFICATION TRIGGER
resource "aws_s3_bucket_notification" "s3_lambda_trigger"{
  count           = var.s3_vars.s3_trigger_type == "lambda-s3_invoker" ? 1 : 0
  bucket          = aws_s3_bucket.bucket.id

  lambda_function {
    lambda_function_arn = var.s3_vars.lambda_arn
    events              = ["s3:ObjectCreated:*"]
    #filter_prefix       = "/"
  }
}
