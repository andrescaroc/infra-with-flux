provider "aws" {
  region = var.region
}

provider "kubectl" {}

provider "kubernetes" {
  config_path = "~/.kube/config"
}

data "aws_availability_zones" "available" {}

module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "3.19.0"

  name = "${var.production_name}-vpc"

  cidr = "10.0.0.0/16"
  azs  = slice(data.aws_availability_zones.available.names, 0, 3)

  private_subnets = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
  public_subnets  = ["10.0.4.0/24", "10.0.5.0/24", "10.0.6.0/24"]

  enable_nat_gateway   = true
  single_nat_gateway   = true
  enable_dns_hostnames = true

  public_subnet_tags = {
    "kubernetes.io/cluster/${var.production_name}" = "shared"
    "kubernetes.io/role/elb"                       = 1
  }

  private_subnet_tags = {
    "kubernetes.io/cluster/${var.production_name}" = "shared"
    "kubernetes.io/role/internal-elb"              = 1
  }
}

module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "19.5.1"

  cluster_name    = var.production_name
  cluster_version = "1.24"

  vpc_id                         = module.vpc.vpc_id
  subnet_ids                     = module.vpc.private_subnets
  cluster_endpoint_public_access = true

  eks_managed_node_group_defaults = {
    ami_type = "AL2_x86_64"
  }

  eks_managed_node_groups = {
    one = {
      name = "node-group-1"

      instance_types = ["t3.xlarge"]

      min_size     = 1
      max_size     = 3
      desired_size = 1
    }

  }
}

resource "null_resource" "update_kubeconfig" {
  triggers = {
    always_run = timestamp()
  }

  provisioner "local-exec" {
    command = "aws eks --region '${var.region}' update-kubeconfig --name '${module.eks.cluster_name}'"
  }

  depends_on = [module.eks]
}

resource "null_resource" "wait_for_production_api_ready" {
  triggers = {
    always_run = timestamp()
  }

  provisioner "local-exec" {
    command = "./kube-api-ready.sh ${var.production_name}"
  }

  depends_on = [null_resource.update_kubeconfig]
}

resource "null_resource" "bootstrap_flux_production" {
  triggers = {
    always_run = timestamp()
  }

  provisioner "local-exec" {
    command = "./bootstrap.sh ${var.repository_name} ${var.production_name}"
  }

  depends_on = [null_resource.wait_for_production_api_ready]
}


resource "k3d_cluster" "local-cluster" {
  name    = var.staging_name
  servers = 1
  image   = "rancher/k3s:v1.24.10-k3s1"
  kubeconfig {
    update_default_kubeconfig = true
    switch_current_context    = true
  }
  depends_on = [null_resource.bootstrap_flux_production]
}

resource "null_resource" "wait_for_staging_api_ready" {
  triggers = {
    always_run = timestamp()
  }

  provisioner "local-exec" {
    command = "./kube-api-ready.sh ${var.staging_name}"
  }

  depends_on = [k3d_cluster.local-cluster, null_resource.bootstrap_flux_production]
}

resource "null_resource" "uninstall_traefik" {
  provisioner "local-exec" {
    command = "./uninstall-traefik.sh"
  }

  depends_on = [null_resource.wait_for_staging_api_ready]
}

resource "null_resource" "bootstrap_flux_staging" {
  triggers = {
    always_run = timestamp()
  }

  provisioner "local-exec" {
    command = "./bootstrap.sh ${var.repository_name} ${var.staging_name}"
  }

  depends_on = [null_resource.uninstall_traefik]
}
