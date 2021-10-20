include "root" {
  path = find_in_parent_folders()
}

# Indicate the input values to use for the variables of the module.
inputs = {
  environment          = "dev"
  cluster              = "morelikeahumanecs"
  vpc_cidr             = "10.0.0.0/16"
  public_subnet_cidrs  = ["10.0.101.0/24", "10.0.102.0/24", "10.0.103.0/24"]
  private_subnet_cidrs = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
  availability_zones   = ["us-east-1a", "us-east-1b", "us-east-1c"]
  max_size             = 4
  min_size             = 2
  desired_capacity     = 2
  instance_type        = "t2.micro"
  aws_ecs_ami          = "ami-0eba366342cb1dfda"
  vpc_id = dependency.vpc.outputs.vpc_id
  public_subnet_ids=dependency.vpc.outputs.public_subnet_ids

  tags = {
    Terraform = "true"
    Environment = "dev"
  }
}

include "envcommon" {
  path   = "${dirname(find_in_parent_folders())}/_envcommon/ecs.hcl"
  expose = true
}

dependency "vpc" {
   config_path = "../vpc"
   skip_outputs = true
  mock_outputs = {
    vpc_id     = "temporary-dummy-id"
    public_subnet_ids = ["temporary-dummy-value"]

  }
}

