## Primary Region Networking (Europe)
module "primary_networking" {
  source = "../Eduhub-modules/networking" # Assuming a local path as per your structure
  # OR source = "git::ssh://git@github.com:your-org/terraform-networking-module.git?ref=main"

  providers = {
    aws = aws.primary
  }

  vpc_cidr_block = var.vpc_cidr_block

  # Subnets in Primary Region
  public_subnets_cidr      = var.public_subnets_cidr
  eks_private_subnets_cidr = var.eks_private_subnets_cidr
  storage_private_subnets_cidr = var.storage_private_subnets_cidr
  
 
  project_name = var.project_name
}

# ## Secondary Region Networking (Another Europe or Peered Region)
# module "secondary_networking" {
#   source = "../../modules/networking" # Assuming a local path as per your structure
#   # OR source = "git::ssh://git@github.com:your-org/terraform-networking-module.git?ref=main"

#   providers = {
#     aws = aws.secondary
#   }

#   vpc_cidr_block = "10.1.0.0/16"

#   # Subnets in Secondary Region
#   public_subnets_cidr      = ["10.1.0.0/20", "10.1.16.0/20"]
#   eks_private_subnets_cidr = ["10.1.32.0/20"]
#   storage_private_subnets_cidr = ["10.1.48.0/20"]

#   # Use the first two AZs in the secondary region
#   availability_zones = [data.aws_availability_zones.secondary.names[0], data.aws_availability_zones.secondary.names[1]]
  
#   project_name = "eduhub-secondary"
# }

module "kubernetes" {
  source = "../Eduhub-modules/eks"  # Adjust path

  providers = {
    aws = aws.primary  
  }

  project_name       = var.project_name
  vpc_id             = module.primary_networking.vpc_id
  eks_subnet_ids     = module.primary_networking.eks_subnet_ids
  kubernetes_version = var.kubernetes_version
  instance_types     = var.instance_types
  min_nodes          = var.min_nodes
  max_nodes          = var.max_nodes
  desired_nodes      = var.desired_nodes
  ssh_key_name       = var.ssh_key_name 
}


# root/main.tf or environments/prod/main.tf
module "databases" {
  source = "../Eduhub-modules/storage"

  providers = {
    aws = aws.primary  
  }  

  project_name                = var.project_name
  vpc_id                      = module.primary_networking.vpc_id
  storage_subnet_ids          = module.primary_networking.storage_subnet_ids
  eks_node_security_group_id  = module.kubernetes.nodes_security_group_id
  db_master_username          = local.db_master_username
  db_master_password          = local.db_master_password
}


module "primary_buckets" {
  source = "../Eduhub-modules/cdn-s3"
  providers = {
    aws = aws.primary
  }

  buckets = {
    "eduhub-videos"      = { lifecycle_rules = [{ transition_days = 90, storage_class = "GLACIER" }] }
    "eduhub-assignments" = {}
    "eduhub-backups" = {}
  }
}

# module "secondary_buckets" {
#   source = "../modules/cdn-s3"
#   providers = {
#     aws = aws.secondary
#   }

#   buckets = {
#     "eduhub-videos-${provider.aws.secondary.region}"       = {}
#     "eduhub-assignments-${provider.aws.secondary.region}" = {}
#     "eduhub-backups-${provider.aws.secondary.region}"     = {}
#   }
# }