resource "aws_lambda_function" "lambda" {
  function_name = var.lambda_name

  role        = data.aws_iam_role.lambda_iam.arn
  description = "Lambda gerada pela plataforma"
  #create_package = false

  # Container Image
  #package_type  = "Image"
  handler       = "bootstrap.file"
  architectures = ["x86_64"]
  runtime       = "provided.al2023"
  #   filename      = "./drop/function.zip"
  filename = "./modules/lambda_functions/drop/function.zip"

  source_code_hash = filebase64sha256("./modules/lambda_functions/drop/function.zip")

  #memory_size                    = min(local.config.mem, 512)
  memory_size                    = 512
  reserved_concurrent_executions = -1
  #  runtime                        = null

  #layers                             = var.layers

  #timeout = min(local.config.timeout, 30) # forca 30 segundos max
  timeout = 30 # forca 30 segundos max

  environment {
    variables = merge({
      REGION        = var.aws_region,
      ENVIRONMENT   = var.environment
      business_unit = var.business_unit
      type          = var.deploy_type
      projeto       = var.project
    },
    var.env_vars)
  }

  vpc_config {
    subnet_ids = [
      var.lambda_sunet1,
      var.lambda_sunet2
    ]
    security_group_ids = [
      var.lambda_sg
    ]

  }

  ephemeral_storage {
    size = 512
  }

  tags = merge({
    info = "Criado pela plataforma"
    },
    try(var.tags, {})
  )

}



data "aws_iam_role" "lambda_iam" {
  name = "${var.environment}_${var.lambda_name}-iam"
}

resource "aws_iam_role_policy" "lambda_iam_role_policy" {
  name   = "${var.lambda_name}_lambda_iam_role_policy"
  role   = data.aws_iam_role.lambda_iam.id
  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "ec2:DescribeNetworkInterfaces",
        "ec2:CreateNetworkInterface",
        "ec2:DeleteNetworkInterface",
        "ec2:DescribeInstances",
        "ec2:AttachNetworkInterface"
      ],
      "Resource": "*"
    }
  ]
}
EOF
}

resource "aws_cloudwatch_log_group" "authorizer_log_group" {
  name              = "/aws/lambda/${var.lambda_name}"
  retention_in_days = var.retention_in_days
}

resource "aws_iam_policy" "lambda_logging" {
  name        = "${var.lambda_name}_lambda_logging_policy"
  path        = "/"
  description = "IAM policy for logging from a lambda"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "logs:CreateLogGroup",
        "logs:CreateLogStream",
        "logs:PutLogEvents"
      ],
      "Resource": "arn:aws:logs:*:*:*",
      "Effect": "Allow"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "lambda_logs" {
  role       = data.aws_iam_role.lambda_iam.name
  policy_arn = aws_iam_policy.lambda_logging.arn
}

resource "aws_lambda_permission" "allow_execution_from_bucket" {
  count          = var.template_selection_s3 == "lambda-s3_invoker" ? 1 : 0
  statement_id   = "AllowExecutionFromS3Bucket"
  action         = "lambda:InvokeFunction"
  function_name  = aws_lambda_function.lambda.arn
  principal      = "s3.amazonaws.com"
  source_arn     = var.s3_vars.s3_arn
  source_account = var.aws_account
}

resource "aws_iam_policy" "lambda_s3_access" {
  count      = (var.template == "lambda-s3") && var.create_s3_buckets ? 1 : 0
  name        = "${var.lambda_name}_lambda_s3_access_policy" 
  path        = "/"
  description = "IAM policy for access from a lambda"

  policy = <<EOF
{
    "Statement": [
        {
            "Action": "s3:GetObject",
            "Effect": "Allow",
            "Resource": "${var.s3_vars.s3_arn}/*",
            "Sid": "s3"
        }
    ],
    "Version": "2012-10-17"
}
EOF
}

resource "aws_iam_role_policy_attachment" "lambda_s3_access_policy" {
  count      = (var.template == "lambda-s3") && var.create_s3_buckets ? 1 : 0
  role       = data.aws_iam_role.lambda_iam.name
  policy_arn = aws_iam_policy.lambda_s3_access[count.index].arn
}

resource "aws_lambda_permission" "allow_execution_from_sqs" {
  count          = var.template_selection_sqs == "lambda-sqs_invoker" ? 1 : 0
  statement_id   = "AllowExecutionFromSqs"
  action         = "lambda:InvokeFunction"
  function_name  = aws_lambda_function.lambda.arn
  principal      = "sqs.amazonaws.com"
  source_arn     = var.sqs_vars.sqs_arn
  source_account = var.aws_account
}

resource "aws_iam_policy" "lambda_sqs_access" {
  #count       = var.sqs_vars.sqs_trigger_type == "lambda-sqs_invoker" ? 1 : 0
  count       = (var.template == "lambda-sqs") && var.create_sqs ? 1 : 0
  name        = "${var.lambda_name}_lambda_sqs_access_policy"
  path        = "/"
  description = "IAM policy for access from a sqs"

  policy = <<EOF
{
    "Statement": [
        {
            "Action": [
                "sqs:SendMessage",
                "sqs:ReceiveMessage",
                "sqs:GetQueueAttributes",
                "sqs:DeleteMessage",
                "sqs:ChangeMessageVisibility"
            ],
            "Effect": "Allow",
            "Resource": "${var.sqs_vars.sqs_arn}*",
            "Sid": "AllowSQSPermissions"
        }
    ],
    "Version": "2012-10-17"
}
EOF
}

resource "aws_iam_role_policy_attachment" "lambda_sqs_access_policy" {
  #count      = var.sqs_vars.sqs_trigger_type == "lambda-sqs_invoker" ? 1 : 0
  count      = (var.template == "lambda-sqs") && var.create_sqs ? 1 : 0
  role       = data.aws_iam_role.lambda_iam.name
  policy_arn = aws_iam_policy.lambda_sqs_access[count.index].arn
}

resource "aws_lambda_function_event_invoke_config" "invoke_config_lambda" {
  function_name                = aws_lambda_function.lambda.arn
  maximum_event_age_in_seconds = 600
  maximum_retry_attempts       = 0

  # destination_config {
  #   on_failure {
  #     destination = "arn"
  #   }

  #   on_success {
  #     destination = "arn"
  #   }
  # }
}