terraform {
  # Deploy version v0.0.1 in prod
  source = "git::git@github.com:ragsonline/terraform-modules.git//terraform-aws-ecs-master//modules/alb?ref=master"
}

locals {
  environment_vars = read_terragrunt_config(find_in_parent_folders("env.hcl"))
  account_vars     = read_terragrunt_config(find_in_parent_folders("account.hcl"))
  env = local.environment_vars.locals.environment
  # Extract out common variables for reuse
  domain_name   = local.account_vars.locals.domain_name
  owner         = local.account_vars.locals.owner
  instance_type = local.environment_vars.locals.instance_type

}
inputs = {
  container_insights = false

  }

