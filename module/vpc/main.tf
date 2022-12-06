terraform {
  required_version = " >= 0.13"
  required_providers {
    ncloud = {
      source = "navercloudplatform/ncloud"
    }
  }
}


resource "ncloud_vpc" "ncp_vpc" {
  name            = var.vpc_name
  ipv4_cidr_block = var.vpc_ipv4_cidr
}

resource "ncloud_subnet" "public_subnet" {
  for_each       = { for subnet in var.subnets : subnet.name => subnet if subnet.subnet_type == "PUBLIC" && var.auto_create_enable }
  vpc_no         = ncloud_vpc.ncp_vpc.id
  subnet         = each.value.subnet
  zone           = local.ncp_zone_info[index(local.public_subnet_names, each.value.name) % var.multiple_zone]
  network_acl_no = ncloud_vpc.ncp_vpc.default_network_acl_no
  subnet_type    = each.value.subnet_type
  usage_type     = each.value.usage_type
  name           = each.value.name
}

resource "ncloud_subnet" "private_subnet" {
  for_each       = { for subnet in var.subnets : subnet.name => subnet if subnet.subnet_type == "PRIVATE" && subnet.usage_type == "GEN" && var.auto_create_enable }
  vpc_no         = ncloud_vpc.ncp_vpc.id
  subnet         = each.value.subnet
  zone           = local.ncp_zone_info[index(local.private_subnet_names, each.value.name) % var.multiple_zone]
  network_acl_no = ncloud_vpc.ncp_vpc.default_network_acl_no
  subnet_type    = each.value.subnet_type
  usage_type     = each.value.usage_type
  name           = each.value.name
}

resource "ncloud_subnet" "loadbalancer_subnet" {
  for_each       = { for subnet in var.subnets : subnet.name => subnet if subnet.subnet_type == "PRIVATE" && subnet.usage_type == "LOADB" && var.auto_create_enable }
  vpc_no         = ncloud_vpc.ncp_vpc.id
  subnet         = each.value.subnet
  zone           = local.ncp_zone_info[index(local.loadbalancer_subnet_names, each.value.name) % var.multiple_zone]
  network_acl_no = ncloud_vpc.ncp_vpc.default_network_acl_no
  subnet_type    = each.value.subnet_type
  usage_type     = each.value.usage_type
  name           = each.value.name
}

locals {
  subnets = merge(ncloud_subnet.public_subnet, ncloud_subnet.private_subnet, ncloud_subnet.loadbalancer_subnet)
}

resource "ncloud_route_table" "public_route_tables" {
  for_each              = { for name in local.public_subnet_names : name => name }
  name                  = format("%s-%s", "rt", each.value)
  vpc_no                = ncloud_vpc.ncp_vpc.id
  supported_subnet_type = "PUBLIC"
  description           = format("%s-%s", "rt", each.value)
}

resource "ncloud_route_table" "private_route_tables" {
  for_each              = { for name in local.private_subnet_names : name => name }
  name                  = format("%s-%s", "rt", each.value)
  vpc_no                = ncloud_vpc.ncp_vpc.id
  supported_subnet_type = "PRIVATE"
  description           = format("%s-%s", "rt", each.value)
}

locals {
  public_route_tables = { for rt_key, rt_value in ncloud_route_table.public_route_tables :
    rt_key => {
      route_table_no = rt_value.id
      subnet_no      = local.subnets[rt_key].id
      zone           = local.ncp_zone_info[index(local.public_subnet_names, rt_key) % var.multiple_zone]
    }
  }

  private_route_tables = { for rt_key, rt_value in ncloud_route_table.private_route_tables :
    rt_key => {
      route_table_no = rt_value.id
      subnet_no      = local.subnets[rt_key].id
      zone           = local.ncp_zone_info[index(local.private_subnet_names, rt_key) % var.multiple_zone]
    }
  }

  route_table_associations = merge(local.public_route_tables, local.private_route_tables)
}

resource "ncloud_route_table_association" "route_table_associationss" {
  for_each = local.route_table_associations

  route_table_no = each.value.route_table_no
  subnet_no      = each.value.subnet_no
}

resource "ncloud_nat_gateway" "nat_gateway" {
  for_each = { for name in slice(local.ncp_zone_info, 0, var.multiple_zone) : format("%s-%s-%s", "ngw", var.vpc_name, lower(name)) => name if var.used_nat_gateway }

  name   = format("%s-%s-%s", "ngw", var.vpc_name, lower(each.value))
  vpc_no = ncloud_vpc.ncp_vpc.id
  zone   = each.value
}

locals {

  nat_gateway = { for ngw_key, ngw_value in ncloud_nat_gateway.nat_gateway :
    ngw_key => {
      nat_gateway_no = ngw_value.nat_gateway_no
      id             = ngw_value.id
      zone           = local.ncp_zone_info[index(keys(ncloud_nat_gateway.nat_gateway), ngw_key) % var.multiple_zone]
    }
  }

  nat_gateway_route = { for rt_key, rt_value in local.private_route_tables :
    rt_key => {
      route_table_no = rt_value.route_table_no
      subnet_no      = rt_value.subnet_no
      nat_gateway_no = [for value in local.nat_gateway : value.nat_gateway_no if value.zone == rt_value.zone]
      name           = format("%s-%s", "rt-ngw", rt_key)
    }
  }

}

resource "ncloud_route" "nat_gateway_routes" {
  for_each = local.nat_gateway_route

  route_table_no         = each.value.route_table_no
  destination_cidr_block = "0.0.0.0/0"
  target_type            = "NATGW"
  target_name            = each.value.name
  target_no              = each.value.nat_gateway_no[0]

}
