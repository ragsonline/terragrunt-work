# Include all settings from the root terragrunt.hcl file
include {
  path = find_in_parent_folders()
}

locals {
  # Automatically load environment-level variables
  environment_vars = read_terragrunt_config(find_in_parent_folders("env.hcl"))
  account_vars     = read_terragrunt_config(find_in_parent_folders("account.hcl"))

  # Extract out common variables for reuse
  env             = local.environment_vars.locals.environment
  owner           = local.account_vars.locals.owner
  region          = local.account_vars.locals.region
  container_name  = "nginx"
  container_image = "nginx:1.18-alpine"
}

dependency "alb" {
  config_path = "../alb"
  mock_outputs = {
    listener_https_arn = "arn:aws:elasticloadbalancing:us-east-1:067653612345:listener/app/app-qa-aware-joey/8c1c7d99b5559a27/36cf5276bff3160d"
    target_group_arn   = "arn:aws:elasticloadbalancing:us-east-1:067653612345:targetgroup/h120200525224707917000000003/e34d2a0306ff19df"
  }
}

dependency "ecs" {
  config_path = "../ecs"
  mock_outputs = {
    cluster_id     = "arn:aws:ecs:us-east-1:067653612345:cluster/app-qa"
    instance_role  = "app-qa-instance-role"
    instance_sg_id = "sg-05d46f4416d012345"
  }
}

include "envcommon" {
  path   = "${dirname(find_in_parent_folders())}/_envcommon/svc.hcl"
  expose = true
}

# These are the variables we have to pass in to use the module specified in the terragrunt configuration above
inputs = {
  version = "~> 1.0.9"

  name                 = "app-${local.env}"
  essential            = true
  region               = "${local.region}"
  container_name       = "${local.container_name}"
  container_image      = "${local.container_image}"
  container_port       = "80"
  task_definition_arn      = "arn:"  
  log_groups           = ["app-${local.env}-${local.container_name}"]
  alb_target_group_arn = dependency.alb.outputs.target_group_arn
  cluster              = dependency.ecs.outputs.cluster_id

  tags = {
    Environment = "${local.env}"
    Owner       = "${local.owner}"
  }
}
