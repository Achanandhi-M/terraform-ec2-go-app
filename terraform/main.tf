module "networking" {
  source               = "./modules/networking"
  vpc_cidr             = var.vpc_cidr
  public_subnet_cidrs  = var.public_subnet_cidrs
  private_subnet_cidrs = var.private_subnet_cidrs
}

module "iam" {
  source    = "./modules/iam"
  s3_bucket = var.s3_bucket
}

module "compute" {
  source               = "./modules/compute"
  vpc_id               = module.networking.vpc_id
  private_subnets      = module.networking.private_subnets
  public_subnets       = module.networking.public_subnets
  instance_type        = var.instance_type
  ami_id               = var.ami_id
  iam_instance_profile = module.iam.instance_profile_name
  s3_bucket            = var.s3_bucket
  s3_key               = var.s3_key
  asg_desired_capacity = var.asg_desired
  alb_sg_id            = module.alb.sg_id
  aws_region           = var.aws_region
}

module "alb" {
  source           = "./modules/alb"
  public_subnets   = module.networking.public_subnets
  target_group_arn = module.compute.target_group_arn
  vpc_id           = module.networking.vpc_id
}

