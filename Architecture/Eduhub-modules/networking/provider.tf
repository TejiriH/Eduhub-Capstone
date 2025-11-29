terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
      # NO version constraint here → version comes from root only
    }
  }
}

