terraform {
  required_version = " >= 0.13"
  required_providers {
    ncloud = {
      source = "navercloudplatform/ncloud"
    }
  }
}

provider "ncloud" {
  access_key  = var.access_key
  secret_key  = var.secret_key
  region      = var.region
  site        = var.site
  support_vpc = var.support_vpc
}

module "vpc" {
  source = "./module/vpc"

  for_each = { for vpc in var.vpc_subnet_create_auto : vpc.vpc_name => vpc }

  auto_create_enable = each.value.auto_create_enable
  vpc_name           = each.value.vpc_name
  vpc_ipv4_cidr      = each.value.vpc_ipv4_cidr
  multiple_zone      = each.value.multiple_zone
  subnets            = each.value.subnets
  used_nat_gateway   = each.value.used_nat_gateway
}
