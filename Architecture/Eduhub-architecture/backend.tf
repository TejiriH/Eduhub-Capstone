terraform {
  backend "s3" {
    bucket         = "eduhub-capstone-prod-tf-state" 
    key            = "primary-region/eduhub-prod.tfstate" 
    region         = "eu-west-1" 
    encrypt        = true
    dynamodb_table = "eduhub-terraform-locks" 
  }
}