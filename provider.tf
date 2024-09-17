provider "aws" {
  region = var.aws_region
  assume_role {
    role_arn     = var.account_role
    session_name = "AWS_TERRAFORM_MGR_EMI"
  }
  default_tags {
    tags = merge({
      ambiente = var.ambiente
      IaC      = "Terraform"
      # projeto       = var.project
      repo = "https://dev.azure.com/alelo/Infraestrutura/_git/plat-${local.repo_contract}-tf"
      # business_unit = var.business_unit
      equipe = var.equipe
      trem   = var.business_unit #TODO
      # squad         = "plataforma"      #var.squad #TODO
      },
      #try(local.tags, {})
      # { "expire-log" = var.retention_in_days }, { "chamado_projeto_finops" = local.local_data.chamado_projeto_finops }
    )
  }
  ignore_tags {
    keys = ["map-migrated"]
  }
}