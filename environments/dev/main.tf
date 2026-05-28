# Call the networking module — creates VPC, subnets, IGW, route tables
module "networking" {
  source = "../../modules/networking"

  project_name         = var.project_name
  environment          = var.environment
  vpc_cidr             = var.vpc_cidr
  public_subnet_cidrs  = var.public_subnet_cidrs
  private_subnet_cidrs = var.private_subnet_cidrs
  availability_zones   = var.availability_zones
}

# Call the security module — creates security groups
# Note: vpc_id comes from the networking module output
module "security" {
  source = "../../modules/security"

  project_name = var.project_name
  environment  = var.environment
  vpc_id       = module.networking.vpc_id # <-- module output reference
}

# Call the compute module — creates EC2 instance
module "compute" {
  source = "../../modules/compute"

  project_name       = var.project_name
  environment        = var.environment
  instance_type      = var.instance_type
  ami_id             = var.ami_id
  key_pair_name      = var.key_pair_name
  subnet_id          = module.networking.public_subnet_ids[0]
  security_group_ids = [module.security.ec2_security_group_id]
}

module "alb" {
  source = "../../modules/alb"
 
  project_name      = var.project_name
  environment       = var.environment
  vpc_id            = module.networking.vpc_id
  public_subnet_ids = module.networking.public_subnet_ids
  alb_sg_id         = module.security.ec2_security_group_id
  ec2_sg_id         = module.security.ec2_security_group_id
  ami_id            = var.ami_id
  instance_type     = var.instance_type
  key_pair_name     = var.key_pair_name
  min_size          = 2
  max_size          = 4
  desired_capacity  = 2
}