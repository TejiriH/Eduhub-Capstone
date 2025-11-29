# # root/db_credentials.tf   ← NEW FILE, DO NOT PUT THIS IN locals.tf

# # These two dummy data sources force Terraform to wait for the provider
# data "aws_caller_identity" "current" {}
# data "aws_region" "current" {}

# # NOW read SSM — this works 100 % of the time
# data "aws_ssm_parameter" "db_master_username" {
#   name            = "/eduhub/${terraform.workspace}/db/master-username"
#   with_decryption = false

#   depends_on = [
#     data.aws_caller_identity.current,
#     data.aws_region.current
#   ]
# }

# data "aws_ssm_parameter" "db_master_password" {
#   name            = "/eduhub/${terraform.workspace}/db/master-password"
#   with_decryption = true

#   depends_on = [
#     data.aws_caller_identity.current,
#     data.aws_region.current
#   ]
# }

# # Now expose as locals — safe because data sources are already resolved
# locals {
#   db_master_username = data.aws_ssm_parameter.db_master_username.value
#   db_master_password = data.aws_ssm_parameter.db_master_password.value
# }