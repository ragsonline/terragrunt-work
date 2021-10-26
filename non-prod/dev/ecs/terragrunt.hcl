include "root" {
  path = find_in_parent_folders()
}

locals {
  environment_vars = read_terragrunt_config(find_in_parent_folders("env.hcl"))
  account_vars     = read_terragrunt_config(find_in_parent_folders("account.hcl"))
  env = local.environment_vars.locals.environment
  owner         = local.account_vars.locals.owner
  instance_type = local.environment_vars.locals.instance_type

}
include "envcommon" {
  path   = "${dirname(find_in_parent_folders())}/_envcommon/ecs.hcl"
  expose = true
}
# Indicate the input values to use for the variables of the module.

inputs = {
  elb_port      = 80
  instance_type = "${local.instance_type}"
  min_size      = 2
  max_size      = 2
  name          = "app-${local.env}"
  server_port   = 8080
  tags = {
    Environment = "${local.env}"
    Owner       = "${local.owner}"
  }
  version     = "~> 3.5.0"
  vpc_id      = dependency.vpc.outputs.vpc_id
  vpc_subnets = dependency.vpc.outputs.private_subnets
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
