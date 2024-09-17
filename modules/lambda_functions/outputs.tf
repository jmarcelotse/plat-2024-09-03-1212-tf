output "lambda_name" {
    description = "Lambda Name:"
    value = aws_lambda_function.lambda.function_name
}

output "lambda_arn" {
    description = "Lambda ARN:"
    value = aws_lambda_function.lambda.arn
}