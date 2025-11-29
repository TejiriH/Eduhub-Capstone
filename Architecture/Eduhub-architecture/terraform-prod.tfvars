vpc_cidr_block = "10.0.0.0/16"
project_name = "Teleios-Eduhub-Academy-prod"
public_subnets_cidr = ["10.0.0.0/20", "10.0.16.0/20"]
eks_private_subnets_cidr = ["10.0.32.0/20", "10.0.48.0/20"]
storage_private_subnets_cidr = ["10.0.64.0/20", "10.0.80.0/20"]

#EKS Module
ssh_key_name = "Teleios"
kubernetes_version = "1.31"
instance_types     = ["t3.medium"]
min_nodes          = 1
max_nodes          = 10
desired_nodes      = 2
