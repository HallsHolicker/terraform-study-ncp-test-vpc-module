variable "region" {
  default = "KR"
}

# public is ncloud, gov is gov-ncloud, fin is fin-ncloud
variable "site" {
  default = "public"
}

# support_vpc is only support if site is public, default value is false
variable "support_vpc" {
  default = true
}

variable "vpc_subnet_create_auto" {
  description = "Auto create subnet"
  type = list(object({
    auto_create_enable = bool
    vpc_name           = string
    vpc_ipv4_cidr      = string
    multiple_zone      = number
    subnets = list(object({
      name        = string
      subnet      = string
      subnet_type = string
      usage_type  = string
    }))
    used_nat_gateway = bool
  }))
  default = [{
    auto_create_enable = true
    vpc_name           = "test-ncp-vpc"
    vpc_ipv4_cidr      = "10.0.0.0/16"
    multiple_zone      = 2
    subnets = [
      {
        name        = "auto-create-public-1"
        subnet      = "10.0.0.0/24"
        subnet_type = "PUBLIC"
        usage_type  = "GEN"
      },
      {
        name        = "auto-create-public-2"
        subnet      = "10.0.1.0/24"
        subnet_type = "PUBLIC"
        usage_type  = "GEN"
      },
      {
        name        = "auto-create-private-1"
        subnet      = "10.0.2.0/24"
        subnet_type = "PRIVATE"
        usage_type  = "GEN"
      },
      {
        name        = "auto-create-private-2"
        subnet      = "10.0.3.0/24"
        subnet_type = "PRIVATE"
        usage_type  = "GEN"
      },
      # {
      #   name        = "auto-create-private-3"
      #   subnet      = "10.0.6.0/24"
      #   subnet_type = "PRIVATE"
      #   usage_type  = "GEN"
      # },
      # {
      #   name        = "auto-create-private-4"
      #   subnet      = "10.0.7.0/24"
      #   subnet_type = "PRIVATE"
      #   usage_type  = "GEN"
      # },
      {
        name        = "auto-create-loadbalancer-1"
        subnet      = "10.0.4.0/24"
        subnet_type = "PRIVATE"
        usage_type  = "LOADB"
      },
      {
        name        = "auto-create-loadbalancer-2"
        subnet      = "10.0.5.0/24"
        subnet_type = "PRIVATE"
        usage_type  = "LOADB"
      }
    ]
    used_nat_gateway = true
  }]
}
