module "iam_role_lambda" {
  
  source = "./modules/iam-assumable-role"

  for_each   = { for b in local.contrato.variables.resources.iamPermissions : b.resourceName => b }
  
  role_name = "${var.environment}_${local.lambda_name}-iam" //nome da role que esta criando, é o que vai aparecer na aws.

  create_role       = true //variável usada para controle do modulo, caso esteja com false ou esteja sem esta linha a policy não será criada.
  role_requires_mfa = false
  # max_session_duration = 3600

  create_custom_role_trust_policy = true
  // trust da role que esta sendo criada.
  custom_role_trust_policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "",
            "Effect": "Allow",
            "Principal": {
                "Service": "lambda.amazonaws.com"
            },
            "Action": "sts:AssumeRole"
        }
    ]
}
EOF
  // arn das policies que deverão ser atachadas na role.
#   custom_role_policy_arns = [
#     module.policy_chatbot_sbx_dc.arn
#   ]

  tags = merge({
    info = "Criado pela plataforma"
    },
    try(each.value.tags, {})
  )
}