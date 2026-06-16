output "app_fqdn" {
  value = azurerm_container_app.fastapi.ingress[0].fqdn
}

output "managed_identity_id" {
  value = azurerm_user_assigned_identity.app.id
}

output "managed_identity_client_id" {
  value = azurerm_user_assigned_identity.app.client_id
}
