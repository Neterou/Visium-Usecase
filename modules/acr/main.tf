resource "azurerm_container_registry" "main" {
  name                = var.acr_name
  resource_group_name = var.resource_group_name
  location            = var.location
  sku                 = "Premium"   # Premium required for Private Endpoint support
  tags                = var.tags

  admin_enabled                 = false  # use Managed Identity, not admin credentials
  public_network_access_enabled = false
}
