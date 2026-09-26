terraform {
  backend "s3" {
    bucket         = "fahad-terraform-state-797260140066"
    key            = "dev/terraform.tfstate"
    region         = "ap-south-1"
    dynamodb_table = "terraform-state-lock"
    encrypt        = true
  }
}