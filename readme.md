# Terraform Test ncp vpc module

테라폼 스터디를 진행하면서 배운것을 통해 만든 ncp vpc test module 입니다.

변수 설정에 따라 vpc, subnet, nat_gateway, route table이 자동 생성 됩니다.

또한 Multiple Zone 설정으로 여러 존에 분산해서 생성도 가능합니다.

## Variable Declaration

### Structure : `variable.tf`


``` hcl
variable "vpc_subnet_create_auto" {
  description = "Auto create subnet"
  type = list(object({
    auto_create_enable = bool       // Auto Create Enable/Disable
    vpc_name           = string     // VPC Name
    vpc_ipv4_cidr      = string     // VPC CIDR
    multiple_zone      = number     // Number of zones to use 
    subnets = list(object({         // Subnet Information
      name        = string          // Subnet Name
      subnet      = string          // Subnet CIDR
      subnet_type = string          // Subent Type | PUBLIC or PRIVATE
      usage_type  = string          // usage_Type | GEN or LOADB | LOADB is loadbalancer
    }))
    used_nat_gateway = bool         // whether to use nat gateway
  }))
  default = []
}

```

## Example 
``` hcl
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
```

## Module Usage

### `main.tf`

``` hcl
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
```


## Reference Site
* [terraform ncloud module](https://github.com/terraform-ncloud-modules/terraform-ncloud-vpc)