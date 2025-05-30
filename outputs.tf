output "id" {
  value = resource.azurerm_container_app.container_app.id
}
output "ingress" {
  value = resource.azurerm_container_app.container_app.ingress
}
output "app_fqdn" {
  value = resource.azurerm_container_app.container_app.ingress[0].fqdn
}

output "latest_revision_fqdn" {
  value = resource.azurerm_container_app.container_app.latest_revision_fqdn
}
output "latest_revision_name" {
  value = resource.azurerm_container_app.container_app.latest_revision_name
}
output "app_gw_rule" {
  value = local.app_gw_rule
}
output "app_gw_backend_target" {
  value = local.app_gw_backend_target
}
