# resource "azurerm_container_app_environment_storage" "storage" {
#   for_each = var.env_storage

#   access_key                   = var.environment_storage_access_key[each.key]
#   access_mode                  = each.value.access_mode
#   account_name                 = each.value.account_name
#   container_app_environment_id = local.container_app_environment_id
#   name                         = each.value.name
#   share_name                   = each.value.share_name
# }