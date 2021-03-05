locals {
  node_pools            = zipmap(keys(var.node_pools), [ for node_pool in values(var.node_pools) : merge(var.node_pool_defaults, node_pool) ])
  additional_node_pools = { for k,v in local.node_pools : k => v if k != var.default_node_pool}

  valid_route_table_ids = (var.identity_type == "SystemAssigned" && length(var.custom_route_table_ids) > 0 ?
                           file("ERROR: custom route tables unavailable with SystemAssigned identity type") : null)

  validate_multiple_node_pools = (((local.node_pools[var.default_node_pool].type != "VirtualMachineScaleSets") && (length(local.additional_node_pools) > 0)) ?
                                    file("ERROR: multiple node pools only allowed when default node pool type is VirtualMachineScaleSets") : null)

  validate_default_node_pool = (local.node_pools[var.default_node_pool].os_type != "Linux" ?
                                file("ERROR: default node pool type must be Linux") : null)

  validate_windows_profile_admin_password = (var.enable_windows_node_pools ? (var.windows_profile_admin_password == "" ?
                                              file("ERROR: windows_profile_admin_password cannot be empty") : null) : null)
}