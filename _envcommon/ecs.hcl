terraform {
  # Deploy version v0.0.1 in prod
  source = "git::git@github.com:ragsonline/terraform-modules.git//terraform-ecs-master?ref=master"
}

locals {
  environment_vars = read_terragrunt_config(find_in_parent_folders("env.hcl"))
  env = local.environment_vars.locals.environment

}
inputs = {
  container_insights = false

  }

