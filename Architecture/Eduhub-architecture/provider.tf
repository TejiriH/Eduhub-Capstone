# Use the correct AWS provider for the primary region
provider "aws" {
  alias  = "primary"
  profile = "Tejiri"
  region = "eu-west-1" # Ireland (AWS equivalent for North Europe/UK)
  # These two lines are the magic fix
  skip_credentials_validation = false
  skip_metadata_api_check     = false
}

# # Use the correct AWS provider for the secondary region
# provider "aws" {
#   alias  = "secondary"
#   region = "eu-central-1" # Frankfurt (AWS equivalent for West Europe)
# }

terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}