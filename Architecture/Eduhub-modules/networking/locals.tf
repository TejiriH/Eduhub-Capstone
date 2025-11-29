# Fetch AZs once
data "aws_availability_zones" "available" {
  state = "available"
}

# Local to keep a global running index across all subnet types
locals {
  azs = data.aws_availability_zones.available.names

  # This creates a flat list of all subnets in creation order
  all_subnet_cidrs = concat(
    var.public_subnets_cidr,
    var.eks_private_subnets_cidr,
    var.storage_private_subnets_cidr
  )

  # Global index → AZ mapping (this is the magic)
  global_az_index = {
    for idx, cidr in local.all_subnet_cidrs :
    cidr => local.azs[idx % length(local.azs)]
  }
}