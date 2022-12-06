output "vpc" {
  value = ncloud_vpc.ncp_vpc
}

output "subnets" {
  value = merge(ncloud_subnet.public_subnet, ncloud_subnet.private_subnet, ncloud_subnet.loadbalancer_subnet)
}

output "public_subnet" {
  value = ncloud_subnet.public_subnet
}

output "private_subnet" {
  value = ncloud_subnet.private_subnet
}

output "loadbalancer_subnet" {
  value = ncloud_subnet.loadbalancer_subnet
}

output "all_route_tables" {
  value = merge(ncloud_route_table.public_route_tables, ncloud_route_table.private_route_tables)
}

output "public_route_tables" {
  value = ncloud_route_table.public_route_tables
}

output "private_route_tables" {
  value = ncloud_route_table.private_route_tables
}

output "nat_gateways" {
  value = ncloud_nat_gateway.nat_gateway
}
