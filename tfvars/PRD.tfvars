############################# Global Vars #############################
account_role  = "arn:aws:iam::109081780288:role/terraform_sts_exec"
aws_account   = "109081780288"
aws_region    = "sa-east-1"
ambiente      = "PRD"
environment   = "PRD"
business_unit = "INFRA"
equipe        = "ADQ"
trem          = "CROSS"

########################### LAMBDA ############################
var_json          = "contratov1.json"
retention_in_days = 5

lambda_sunet1 = "subnet-0b1496f55e0c891b2" # 10.114.114.0/24
lambda_sunet2 = "subnet-0e804cbe2b230b5a2" # 10.114.115.0/24

lambda_sg = "sg-0a8a707a222ebd08f" 