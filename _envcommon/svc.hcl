terraform {
  # Deploy version v0.0.1 in prod
  source = "git::git@github.com:ragsonline/terraform-modules.git//terraform-aws-ecs-master//modules/service?ref=master"
}
locals {
  environment_vars = read_terragrunt_config(find_in_parent_folders("env.hcl"))
  account_vars     = read_terragrunt_config(find_in_parent_folders("account.hcl"))
  env = local.environment_vars.locals.environment
  # Extract out common variables for reuse
  owner           = local.account_vars.locals.owner
  region          = local.account_vars.locals.region
  container_name  = "nginx"
  container_image = "nginx:1.18-alpine"

}
inputs = {
  container_insights = false

  }

