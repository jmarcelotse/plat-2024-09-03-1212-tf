module "sqs_alelo" {
  depends_on = [module.lambda_alelo]
  source     = "./modules/sqs_queues"
  for_each   = { for b in local.contrato.variables.resources.sqsQueues : b.resourceName => b }

  sqs_name       = "${each.value.resourceName}-${lower(var.ambiente)}-sqs"
  sqs_vars       = local.sqs_vars
  sqs_attributes = each.value.specification.attributes

  tags = each.value.tags

  trigger_type = each.value.specification.trigger.type
  lambda_name  = "${each.value.specification.trigger.from}-${lower(var.ambiente)}-lbd"
  #sns_name     = each.value.specification.subscription.name
  sns_name    = length(each.value.specification.subscription.name) > 0 ? each.value.specification.subscription.name : "none"
  aws_region  = var.aws_region
  aws_account = var.aws_account
  environment = var.environment

}