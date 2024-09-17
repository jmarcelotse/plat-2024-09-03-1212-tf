output "sqs_id" {
    description = "Sqs ID:"
    value = aws_sqs_queue.sqs.id
}

output "sqs_arn" {
    description = "Sqs ARN:"
    value = try(aws_sqs_queue.sqs.arn,
                null
            )
}