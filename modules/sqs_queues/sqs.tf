resource "aws_sqs_queue" "sqs" {
	name					              = "${var.sqs_name}"
	delay_seconds				        = var.environment == "DEV" ? var.sqs_attributes.dev.sqsDelaySeconds : var.environment == "HML" ? var.sqs_attributes.hml.sqsDelaySeconds : var.environment == "PRD" ? var.sqs_attributes.prd.sqsDelaySeconds: 0
	max_message_size			      = var.max_message_size
	message_retention_seconds		= var.message_retention_seconds
	receive_wait_time_seconds		= var.receive_wait_time_seconds
  visibility_timeout_seconds  = var.environment == "DEV" ? var.sqs_attributes.dev.VisibilityTimeout : var.environment == "HML" ? var.sqs_attributes.hml.VisibilityTimeout : var.environment == "PRD" ? var.sqs_attributes.prd.VisibilityTimeout: 0

  tags = merge({
    info          = "Criado pela plataforma"
    },
    try(var.tags, {})
  )
}

resource "aws_lambda_event_source_mapping" "event_source_mapping" {
  depends_on = [ aws_sqs_queue.sqs ]
  count            = var.trigger_type == "invoker" ? 1 : 0
  batch_size       = 1
  event_source_arn = aws_sqs_queue.sqs.arn
  enabled          = true
  function_name    = var.lambda_name
}
