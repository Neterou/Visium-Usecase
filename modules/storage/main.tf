resource "azurerm_storage_account" "main" {
  name                     = var.storage_account_name
  resource_group_name      = var.resource_group_name
  location                 = var.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
  tags                     = var.tags

  # No public internet access — all access via Private Endpoint
  public_network_access_enabled   = false
  allow_nested_items_to_be_public = false

  network_rules {
    default_action = "Deny"
    bypass         = ["AzureServices"]
  }

  blob_properties {
    delete_retention_policy {
      days = 7
    }
  }
}

# ── Blob container for media files ────────────────────────────────────────────
resource "azurerm_storage_container" "media" {
  name                  = "media"
  storage_account_name  = azurerm_storage_account.main.name
  container_access_type = "private"
}

# ── Private Endpoint ──────────────────────────────────────────────────────────
resource "azurerm_private_endpoint" "storage" {
  name                = "pe-${var.storage_account_name}"
  location            = var.location
  resource_group_name = var.resource_group_name
  subnet_id           = var.private_endpoint_subnet_id
  tags                = var.tags

  private_service_connection {
    name                           = "psc-storage"
    private_connection_resource_id = azurerm_storage_account.main.id
    subresource_names              = ["blob"]
    is_manual_connection           = false
  }

  # Link to the existing Private DNS Zone in the hub
  private_dns_zone_group {
    name                 = "pdz-storage"
    private_dns_zone_ids = [var.private_dns_zone_id]
  }
}
