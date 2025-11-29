# root/locals.tf  (add this at the top)

# Force SSM data sources to use the exact same credentials as the rest of Terraform
data "aws_ssm_parameter" "db_master_username" {
  provider        = aws.primary                     # ← THIS LINE IS THE FIX
  name            = "/eduhub/${terraform.workspace}/db/master-username"
  with_decryption = false                   # it's a normal String, not SecureString
}

data "aws_ssm_parameter" "db_master_password" {
  provider        = aws.primary                  # ← THIS LINE IS THE FIX
  name            = "/eduhub/${terraform.workspace}/db/master-password"
  with_decryption = true                    # this one IS SecureString
}

locals {
  db_master_username = data.aws_ssm_parameter.db_master_username.value
  db_master_password = data.aws_ssm_parameter.db_master_password.value
}