variable "auto_create_enable" {
  description = "Auto create subnet"
  type        = bool
}

variable "vpc_name" {
  description = "VPC Name"
  type        = string
}

variable "vpc_ipv4_cidr" {
  description = "VPC IPv4 CIDR"
  type        = string

  validation {
    condition     = can(regex("^(10.(1?[0-9]?[0-9]|2[0-4][0-9]|25[0-5]).(1?[0-9]?[0-9]|2[0-4][0-9]|25[0-5]).(1?[0-9]?[0-9]|2[0-4][0-9]|25[0-5])|172.(1[6-9]|2[0-9]|3[0-1]).(1?[0-9]?[0-9]|2[0-4][0-9]|25[0-5]).(1?[0-9]?[0-9]|2[0-4][0-9]|25[0-5])|192.168.(1?[0-9]?[0-9]|2[0-4][0-9]|25[0-5]).(1?[0-9]?[0-9]|2[0-4][0-9]|25[0-5]))/(1[6-9]|2[0-8])", var.vpc_ipv4_cidr))
    error_message = "The IP address range of the VPC must be /16 to /28 within the ( 10.0.0.0/8, 172.16.0.0/12, 192.168.0.0/16 )"
  }
}

variable "multiple_zone" {
  description = "How many use VPC Multi Zone"
  type        = number
}

variable "subnets" {
  description = "Subnet Information"
  type        = list(any)

  validation {
    condition     = length(var.subnets) <= 200
    error_message = "Max subnet limit 200 under. Setting subnet count is ${length(var.subnets)}"
  }
}

variable "used_nat_gateway" {
  description = "Check to use nat gateway"
  type        = bool
}

locals {
  public_subnet_names       = [for subnet in var.subnets : subnet.name if subnet.subnet_type == "PUBLIC"]
  private_subnet_names      = [for subnet in var.subnets : subnet.name if subnet.subnet_type == "PRIVATE" && subnet.usage_type == "GEN"]
  loadbalancer_subnet_names = [for subnet in var.subnets : subnet.name if subnet.subnet_type == "PRIVATE" && subnet.usage_type == "LOADB"]
}

locals {
  ncp_zone_info       = sort([for zones in data.ncloud_zones.ncp_zones.zones : zones.zone_code])
  multiple_zone_msg   = "Multiple Zone count over. You can use ${length(local.ncp_zone_info)} zones : ${join(", ", [for zone in local.ncp_zone_info : format("%s", zone)])}"
  multiple_zone_check = regex("^${local.multiple_zone_msg}$", var.auto_create_enable ? (length(local.ncp_zone_info) >= var.multiple_zone ? local.multiple_zone_msg : "") : local.multiple_zone_msg)
}
