variable "project_name" {
  description = "The name of the project to tag resources"
  type        = string
  default     = "eduhub-academy"
}

variable "vpc_cidr_block" {
  description = "CIDR block for the VPC"
  type        = string
}

variable "public_subnets_cidr" {
  description = "List of CIDR blocks for the public subnets (e.g., for Load Balancers)"
  type        = list(string)
  default     = ["10.0.0.0/20", "10.0.16.0/20"]
}

variable "eks_private_subnets_cidr" {
  description = "List of CIDR blocks for the private EKS subnets"
  type        = list(string)
  default     = ["10.0.32.0/20"]
}

variable "storage_private_subnets_cidr" {
  description = "List of CIDR blocks for the private Storage subnets (e.g., for RDS/Redis)"
  type        = list(string)
  default     = ["10.0.48.0/20"]
}

variable "kubernetes_version" { type = string }
variable "instance_types" { type = list(string) }
variable "min_nodes" { type = number }
variable "max_nodes" { type = number }
variable "desired_nodes" { type = number }
variable "ssh_key_name" { type = string  }