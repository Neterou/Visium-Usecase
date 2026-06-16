output "resource_group_name" {
  value = azurerm_resource_group.main.name
}

output "vnet_id" {
  value = module.networking.vnet_id
}

output "container_app_fqdn" {
  description = "Internal FQDN of the Container App (only reachable on company network)"
  value       = module.container_apps.app_fqdn
}

output "acr_login_server" {
  value = module.acr.login_server
}

output "key_vault_uri" {
  value = module.keyvault.key_vault_uri
}

output "storage_account_name" {
  value = module.storage.storage_account_name
}
