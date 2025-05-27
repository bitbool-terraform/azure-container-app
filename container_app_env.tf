data "azurerm_subnet" "env_subnet" {
  name                 = var.env_subnet
  virtual_network_name = var.vnet
  resource_group_name  = var.resource_group
}

data "azurerm_container_app_environment" "container_env" {
  count = var.create_env == false ? 1 : 0

  name                = var.env_name
  resource_group_name = var.resource_group
}

resource "azurerm_container_app_environment" "container_env" {
  count = var.create_env == true ? 1 : 0

  location                       = var.location
  name                           = var.env_name
  resource_group_name            = var.resource_group
  infrastructure_subnet_id       = data.azurerm_subnet.env_subnet.id
  internal_load_balancer_enabled = var.internal_load_balancer_enabled
  zone_redundancy_enabled        = var.zone_redundancy_enabled
  logs_destination               = var.logs_destination

  dynamic "workload_profile" {
    for_each = var.workload_profiles

    content {
        name                  = workload_profile.key
        workload_profile_type = lookup(workload_profile.value,"type","Consumption")
        minimum_count         = lookup(workload_profile.value,"minimum_count",1)
        maximum_count         = lookup(workload_profile.value,"maximum_count",1)
    }
  }
}