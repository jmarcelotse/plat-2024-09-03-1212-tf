output "show_mylocal" {
  value = local.contrato
}

output "sqs_module_output_arn" {
  value = module.sqs_alelo
}

output "s3_module_output_arn" {
  value = module.s3_bucket_alelo
}

output "iam_role_lambda_module_output" {
  value = module.iam_role_lambda
}