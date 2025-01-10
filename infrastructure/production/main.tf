locals {
  projectName = var.project_name
  clusterName = var.cluster_name
}

////////////////////////////////////////////////////////////////////////////////////////////////


module "vpc-1" {
  source = "../modules/vpc/"
  vpc_cidr_block = "10.0.0.0/16"

  project_name = local.projectName
  eks_name = local.clusterName

  private_subnets = [
    { cidr = "10.0.1.0/24", az = "us-east-1a" },
    { cidr = "10.0.2.0/24", az = "us-east-1b" }
  ]

  public_subnets = [
    { cidr = "10.0.3.0/24", az = "us-east-1a" },
    { cidr = "10.0.4.0/24", az = "us-east-1b" }
  ]

  create_nat_gateway = true

}

////////////////////////////////////////////////////////////////////////////////////////////////


module "eks" {
  source         = "../modules/eks/"
  project_name = local.projectName
  eks_name = local.clusterName
  eks_version    = "1.31"
  private_subnets = module.vpc-1.private_subnet_ids
  public_subnets  = module.vpc-1.public_subnet_ids
  instance_types = ["t2.medium"]
  desired_size   = 2
  max_size       = 10
  min_size       = 1
  endpoint_private_access = false
  endpoint_public_access = true
  region                = var.region
  vpc_id                = module.vpc-1.vpc_id

}


//////////////////////////////////////////////////////////////

module "ec2" {
  source          = "../modules/management_server"
  project_name = local.projectName
  instanceName = "cicd"
  vpc_id             = module.vpc-1.vpc_id
  public_subnet_id   = module.vpc-1.public_subnet_ids[0]
  instance_type      = "t2.medium"
  key_name           = "demo1_key"
  entry_point_script = "./scripts/script.sh"
  provisioner_script = "./scripts/provisioner-cicd.sh"
  eks_dependency     = module.eks.eks_cluster_name
}


