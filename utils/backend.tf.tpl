terraform {
  backend \"s3\" {
    bucket     = \"terraform-alelo\"
    key        = \"AWS/${ACCOUNT_ID}_${AMBIENTE^^}/${RESULT_DIR}.tfstate\"
    region     = \"us-east-1\"
  }
}
