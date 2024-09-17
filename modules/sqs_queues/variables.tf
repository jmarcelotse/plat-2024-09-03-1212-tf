variable "sqs_name" {}
variable "sqs_vars" {}
variable "max_message_size" {
    default = "262144"
}
variable "message_retention_seconds" {
    default = "345600"
}
variable "receive_wait_time_seconds" {
    default = "0"
}
variable "tags" {}
variable "trigger_type" {}
variable "lambda_name" {}
variable "sqs_attributes" {
}
variable "environment" {
  # enviroment tfvars
}
variable "aws_region" {}
variable "aws_account" {}
variable "sns_name" {}