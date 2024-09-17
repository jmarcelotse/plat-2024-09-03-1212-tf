resource "aws_sqs_queue_policy" "sns-integration-policy" {
  count = var.sns_name == "none" ? 0 : 1
  
  queue_url = aws_sqs_queue.sqs.id

  policy = <<EOF

{
  "Version": "2012-10-17",
  "Id": "sqspolicy",
  "Statement": [
    {
      "Sid": "__owner_statement",
      "Effect": "Allow",
      "Principal": {
        "Service": [
          "sns.amazonaws.com",
          "kms.amazonaws.com"
        ],
        "AWS": "arn:aws:iam::${var.aws_account}:root"
      },
      "Action": "SQS:*",
      "Resource": "${aws_sqs_queue.sqs.arn}"
    },
    {
      "Sid": "topic-subscription-arn:aws:sns:sa-east-1:${var.aws_account}:${var.sns_name}-${lower(var.environment)}-sns",
      "Effect": "Allow",
      "Principal": {
        "AWS": "*"
      },
      "Action": [ "sqs:DeleteMessage",
                  "sqs:ReceiveMessage",
                  "sqs:GetQueueAttributes",
                  "sqs:GetQueueUrl",
                  "sqs:SendMessage"
                  ],
      "Resource": "${aws_sqs_queue.sqs.arn}",
      "Condition": {
        "ArnLike": {
          "aws:SourceArn": "arn:aws:sns:sa-east-1:${var.aws_account}:${var.sns_name}-${lower(var.environment)}-sns"
        }
      }
    }
  ]
}
EOF
}