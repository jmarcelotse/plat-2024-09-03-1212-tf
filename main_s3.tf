module "s3_bucket_alelo" {
  depends_on = [module.lambda_alelo]
  source     = "./modules/s3_bucket"
  for_each   = { for b in local.contrato.variables.resources.s3Buckets : b.resourceName => b }

  bucket_name = "${each.value.resourceName}-${lower(var.ambiente)}-s3"
  s3_vars     = local.s3_vars
  tags        = each.value.tags
}