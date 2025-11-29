variable "project_name" { type = string }
variable "vpc_id" { type = string }
variable "storage_subnet_ids" { type = list(string) }
variable "eks_node_security_group_id" { type = string }
variable "db_master_username" { type = string }
variable "db_master_password" {
  type      = string
  sensitive = true
}