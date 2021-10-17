terraform {
  source = "tfr:///terraform-aws-modules/vpc/aws?version=3.5.0"
}

locals {
  environment_vars = read_terragrunt_config(find_in_parent_folders("env.hcl"))
  env = local.environment_vars.locals.environment

}
inputs = {
  enable_nat_gateway = false
  enable_vpn_gateway = false
  }

