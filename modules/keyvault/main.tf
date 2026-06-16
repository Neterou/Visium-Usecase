resource "azurerm_key_vault" "main" {
  name                       = var.key_vault_name
  location                   = var.location
  resource_group_name        = var.resource_group_name
  tenant_id                  = var.tenant_id
  sku_name                   = "standard"
  tags                       = var.tags

  # Disable public access — all traffic must go through Private Endpoint
  public_network_access_enabled = false

  # Use RBAC instead of legacy access policies (Key Vault Secrets User role)
  enable_rbac_authorization = true

  network_acls {
    bypass         = "AzureServices"
    default_action = "Deny"
  }

  # Purge protection is configurable per environment.
  # Once enabled it CANNOT be disabled — and a destroyed vault can't be
  # recreated with the same name for 7 days. Off in dev, on in prod.
  purge_protection_enabled   = var.purge_protection_enabled
  soft_delete_retention_days = 7

  # Guard against accidental destroy. Terraform requires this to be a literal,
  # not a variable. To intentionally destroy: remove this block in a PR, merge,
  # then run destroy as a separate change.
  lifecycle {
    prevent_destroy = true
  }
}

# ── Private Endpoint ──────────────────────────────────────────────────────────
resource "azurerm_private_endpoint" "keyvault" {
  name                = "pe-${var.key_vault_name}"
  location            = var.location
  resource_group_name = var.resource_group_name
  subnet_id           = var.private_endpoint_subnet_id
  tags                = var.tags

  private_service_connection {
    name                           = "psc-keyvault"
    private_connection_resource_id = azurerm_key_vault.main.id
    subresource_names              = ["vault"]
    is_manual_connection           = false
  }

  # Link to the existing Private DNS Zone in the hub for automatic A-record creation
  private_dns_zone_group {
    name                 = "pdz-keyvault"
    private_dns_zone_ids = [var.private_dns_zone_id]
  }
}
