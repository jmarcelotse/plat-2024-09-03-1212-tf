locals {
  #read json vars
  contrato               = jsondecode(file("${path.module}/${var.var_json}"))
  template               = local.contrato.variables.resources.lambdaFunctions[0].specification.template
  template_selection_s3  = try("${local.template}_${local.contrato.variables.resources.s3Buckets[0].specification.trigger.type}", "")
  template_selection_sqs = try("${local.template}_${local.contrato.variables.resources.sqsQueues[0].specification.trigger.type}", "")
  lambda_name_contract   = local.contrato.variables.resources.lambdaFunctions[0].resourceName
  lambda_name            = "${local.lambda_name_contract}-${lower(var.ambiente)}-lbd"
  lambda_arn             = "arn:aws:lambda:sa-east-1:${var.aws_account}:function:${local.lambda_name}"
  repo_contract          = local.contrato.variables.resources.lambdaFunctions[0].specification.git.repo

  createS3Buckets = length(local.contrato.variables.resources.s3Buckets) > 0 ? true : false
  createSQS       = length(local.contrato.variables.resources.sqsQueues) > 0 ? true : false

  #s3info
  s3_vars = {
    count = local.template == "lambda-s3"

    s3_trigger_type  = try("${local.template_selection_s3}", "")
    s3_name_contract = try("${local.contrato.variables.resources.s3Buckets[0].resourceName}", "")
    s3_arn           = try("${"arn:aws:s3:::${lower(local.contrato.variables.resources.s3Buckets[0].resourceName)}-${lower(var.ambiente)}-s3"}", "")
    repo             = try("${local.repo_contract}", "")
    lambda_arn       = try("${local.lambda_arn}", "")
    lambda_name      = try("${local.lambda_name}", "")
  }

  #sqsinfo
  sqs_vars = {
    count = local.template == "lambda-sqs"

    sqs_trigger_type  = try("${local.template_selection_sqs}", "")
    sqs_name_contract = try("${local.contrato.variables.resources.sqsQueues[0].resourceName}", "")
    sqs_arn           = try("${"arn:aws:sqs:sa-east-1:${var.aws_account}:${lower(local.contrato.variables.resources.sqsQueues[0].resourceName)}-${lower(var.ambiente)}-sqs"}", "")
    repo              = try("${local.repo_contract}", "")
    lambda_arn        = try("${local.lambda_arn}", "")
    lambda_name       = try("${local.lambda_name}", "")
  }

  #dlqinfo
  dlq_vars = {

    #sqs_trigger_type  = try("${local.template_selection_sqs}", "")
    sqs_name_contract = try("${local.contrato.variables.resources.dlqQueues[0].resourceName}", "")
    sqs_arn           = try("${"arn:aws:sqs:sa-east-1:${var.aws_account}:${lower(local.contrato.variables.resources.dlqQueues[0].resourceName)}-${lower(var.ambiente)}-sqs-dlq"}", "")
    repo              = try("${local.repo_contract}", "")
    lambda_arn        = try("${local.lambda_arn}", "")
    lambda_name       = try("${local.lambda_name}", "")
  }

  #snsinfo
  sns_vars = {

    sns_trigger_type  = try("${local.template_selection_sqs}", "")
    sns_name_contract = try("${local.contrato.variables.resources.snsTopics[0].resourceName}", "")
    sns_arn           = try("${"arn:aws:sns:sa-east-1:${var.aws_account}:${lower(local.contrato.variables.resources.snsTopics[0].resourceName)}-${lower(var.ambiente)}-sns"}", "")
    sns_endpoint      = try("${local.contrato.variables.resources.snsTopics[0].specification.endpoints[0]}", "")
    repo              = try("${local.repo_contract}", "")
    lambda_arn        = try("${local.lambda_arn}", "")
    lambda_name       = try("${local.lambda_name}", "")
  }
}

module "lambda_alelo" {
  source   = "./modules/lambda_functions"
  for_each = { for b in local.contrato.variables.resources.lambdaFunctions : b.resourceName => b }

  lambda_name = local.lambda_name
  project     = each.value.specification.git.project
  repo        = each.value.specification.git.repo
  deploy_type = "terraform"
  artifactid  = each.value.specification.template
  tags        = each.value.tags
  env_vars    = var.environment == "DEV" ? each.value.specification.environmentVariables.dev : var.environment == "HML" ? each.value.specification.environmentVariables.hml : var.environment == "PRD" ? each.value.specification.environmentVariables.prd : {}

  environment       = var.environment
  retention_in_days = var.retention_in_days
  lambda_sunet1     = var.lambda_sunet1
  lambda_sunet2     = var.lambda_sunet2
  lambda_sg         = var.lambda_sg
  aws_region        = var.aws_region
  aws_account       = var.aws_account
  business_unit     = var.business_unit

  template               = local.template
  template_selection_s3  = local.template_selection_s3
  template_selection_sqs = local.template_selection_sqs
  s3_vars                = local.s3_vars
  sqs_vars               = local.sqs_vars

  create_s3_buckets = local.createS3Buckets
  create_sqs        = local.createSQS

}