resource "azurerm_container_registry" "main" {
  name                = var.acr_name
  resource_group_name = var.resource_group_name
  location            = var.location
  sku                 = "Premium"   # Premium required for Private Endpoint support
  tags                = var.tags

  admin_enabled                 = false  # use Managed Identity, not admin credentials
  public_network_access_enabled = false
}

# ── Private Endpoint ──────────────────────────────────────────────────────────
# Without this, ACA cannot pull images because public access is disabled.
resource "azurerm_private_endpoint" "acr" {
  name                = "pe-${var.acr_name}"
  location            = var.location
  resource_group_name = var.resource_group_name
  subnet_id           = var.private_endpoint_subnet_id
  tags                = var.tags

  private_service_connection {
    name                           = "psc-acr"
    private_connection_resource_id = azurerm_container_registry.main.id
    subresource_names              = ["registry"]
    is_manual_connection           = false
  }

  # Link to existing hub Private DNS Zone for automatic A-record registration
  private_dns_zone_group {
    name                 = "pdz-acr"
    private_dns_zone_ids = [var.private_dns_zone_id]
  }
}
