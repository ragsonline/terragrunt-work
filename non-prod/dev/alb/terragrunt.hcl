
# Include all settings from the root terragrunt.hcl file
include {
  path = find_in_parent_folders()
}

dependency "ecs" {
  config_path = "../ecs"
  mock_outputs = {
    cluster_id     = "arn:aws:ecs:us-east-1:067653612345:cluster/app-qa"
    instance_role  = "app-qa-instance-role"
    instance_sg_id = "sg-05d46f4416d012345"
  }
}

dependency "vpc" {
  config_path = "../vpc"
  mock_outputs = {
    vpc_id = "vpc-012341a0dd8b01234"
    private_subnets = [
      "subnet-003601fe683fd1111",
      "subnet-0f0787cffc6ae1112",
      "subnet-00e05034aa90b1112"
    ],
  }
}

locals {
  # Automatically load environment-level variables
  environment_vars = read_terragrunt_config(find_in_parent_folders("env.hcl"))
  account_vars     = read_terragrunt_config(find_in_parent_folders("account.hcl"))

  # Extract out common variables for reuse
  env           = local.environment_vars.locals.environment
  domain_name   = local.account_vars.locals.domain_name
  owner         = local.account_vars.locals.owner
  instance_type = local.environment_vars.locals.instance_type
}

include "envcommon" {
  path   = "${dirname(find_in_parent_folders())}/_envcommon/alb.hcl"
  expose = true
}
# These are the variables we have to pass in to use the module specified in the terragrunt configuration above
inputs = {
  elb_port      = 80
  cluster_id    = dependency.ecs.outputs.cluster_id
  domain_name   = "${local.domain_name}"
  host_name     = "app-${local.env}"
  instance_role = dependency.ecs.outputs.instance_role
  backend_sg_id = dependency.ecs.outputs.instance_sg_id
  instance_type = "${local.instance_type}"
  min_size      = 2
  max_size      = 2
  name          = "app-${local.env}"
  version     = "~> 3.5.0"
  tags = {
    Environment = "${local.env}"
    Owner       = "${local.owner}"
  }
  server_port = 8080
  vpc_id      = dependency.vpc.outputs.vpc_id
  vpc_subnets = dependency.vpc.outputs.private_subnets
}
