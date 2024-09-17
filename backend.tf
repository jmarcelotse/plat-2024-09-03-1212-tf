terraform {
  backend "s3" {
    bucket = "terraform-alelo"
    key    = "AWS/224753950670_DEV/plat-2024-09-03-1212-tf.tfstate"
    region = "us-east-1"
  }
}
