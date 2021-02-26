locals {
  node_pools            = zipmap(keys(var.node_pools), [ for node_pool in values(var.node_pools) : merge(var.node_pool_defaults, node_pool) ])
  additional_node_pools = { for k,v in local.node_pools : k => v if k != var.default_node_pool}

  distinct_subnet_ids = compact(distinct([ for node_pool in local.node_pools : node_pool.subnet_id ]))
  match_subnets       = { for subnet in local.distinct_subnet_ids : subnet => [ for k,v in local.node_pools : k if v.subnet_id == subnet] }
  subnet_info         = { for k,v in local.match_subnets : 
                          k => { id                          = local.node_pools[v[0]].subnet_id
                                 resource_group_name         = local.node_pools[v[0]].subnet_resource_group_name
                                 network_security_group_name = local.node_pools[v[0]].subnet_network_security_group_name
                                 custom_route_table_id       = local.node_pools[v[0]].subnet_custom_route_table_id }
  }
  custom_route_table_ids = toset(compact([ for subnet in local.subnet_info : subnet.custom_route_table_id ]))


  validate_windows_profile_admin_password = (var.enable_windows_node_pools ? (var.windows_profile_admin_password == "" ? file("ERROR: windows_profile_admin_password cannot be empty") : null) : null)
}