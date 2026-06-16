terraform {
  required_version = ">= 1.6.0"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.90"
    }
  }

  # Backend configuration is passed via -backend-config flag per environment
  # so that dev and prod have separate state files.
  # See: environments/{dev,prod}/backend.hcl
  backend "azurerm" {}
}

provider "azurerm" {
  features {
    key_vault {
      purge_soft_delete_on_destroy = false
    }
  }
}

# ── Resource Group ────────────────────────────────────────────────────────────
resource "azurerm_resource_group" "main" {
  name     = var.resource_group_name
  location = var.location
  tags     = var.tags
}

# ── Networking ────────────────────────────────────────────────────────────────
module "networking" {
  source = "./modules/networking"

  resource_group_name = azurerm_resource_group.main.name
  location            = var.location
  tags                = var.tags

  vnet_name          = "vnet-usecase-private-01"
  vnet_address_space = ["10.0.0.0/24"]
  hub_vnet_id        = var.hub_vnet_id
}

# ── Azure Container Registry ──────────────────────────────────────────────────
module "acr" {
  source = "./modules/acr"

  resource_group_name = azurerm_resource_group.main.name
  location            = var.location
  tags                = var.tags

  acr_name                   = var.acr_name
  private_endpoint_subnet_id = module.networking.misc_subnet_id
  private_dns_zone_id        = var.acr_private_dns_zone_id
}

# ── Key Vault ─────────────────────────────────────────────────────────────────
module "keyvault" {
  source = "./modules/keyvault"

  resource_group_name = azurerm_resource_group.main.name
  location            = var.location
  tags                = var.tags

  key_vault_name             = var.key_vault_name
  tenant_id                  = var.tenant_id
  private_endpoint_subnet_id = module.networking.pe_subnet_id
  private_dns_zone_id        = var.keyvault_private_dns_zone_id
  purge_protection_enabled   = var.purge_protection_enabled
}

# ── Storage Account ───────────────────────────────────────────────────────────
module "storage" {
  source = "./modules/storage"

  resource_group_name = azurerm_resource_group.main.name
  location            = var.location
  tags                = var.tags

  storage_account_name       = var.storage_account_name
  private_endpoint_subnet_id = module.networking.pe_subnet_id
  private_dns_zone_id        = var.storage_private_dns_zone_id
}

# ── Container Apps ────────────────────────────────────────────────────────────
module "container_apps" {
  source = "./modules/container_apps"

  resource_group_name = azurerm_resource_group.main.name
  location            = var.location
  tags                = var.tags

  aca_env_name       = var.aca_env_name
  aca_app_name       = var.aca_app_name
  aca_subnet_id      = module.networking.aca_subnet_id
  acr_login_server   = module.acr.login_server
  acr_id             = module.acr.acr_id
  key_vault_id       = module.keyvault.key_vault_id
  storage_account_id = module.storage.storage_account_id
  image_tag          = var.image_tag
}
