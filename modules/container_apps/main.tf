# ── User-Assigned Managed Identity ───────────────────────────────────────────
resource "azurerm_user_assigned_identity" "app" {
  name                = "id-${var.aca_app_name}"
  location            = var.location
  resource_group_name = var.resource_group_name
  tags                = var.tags
}

# ── RBAC: AcrPull on ACR ─────────────────────────────────────────────────────
resource "azurerm_role_assignment" "acr_pull" {
  scope                = var.acr_id
  role_definition_name = "AcrPull"
  principal_id         = azurerm_user_assigned_identity.app.principal_id
}

# ── RBAC: Key Vault Secrets User ──────────────────────────────────────────────
resource "azurerm_role_assignment" "kv_secrets_user" {
  scope                = var.key_vault_id
  role_definition_name = "Key Vault Secrets User"
  principal_id         = azurerm_user_assigned_identity.app.principal_id
}

# ── RBAC: Storage Blob Data Contributor ───────────────────────────────────────
resource "azurerm_role_assignment" "storage_blob" {
  scope                = var.storage_account_id
  role_definition_name = "Storage Blob Data Contributor"
  principal_id         = azurerm_user_assigned_identity.app.principal_id
}

# ── Container Apps Environment (VNet-injected, internal-only) ────────────────
resource "azurerm_container_app_environment" "main" {
  name                       = var.aca_env_name
  location                   = var.location
  resource_group_name        = var.resource_group_name
  tags                       = var.tags

  infrastructure_subnet_id       = var.aca_subnet_id
  internal_load_balancer_enabled = true   # no public IP, only reachable via VNet
}

# ── Container App ─────────────────────────────────────────────────────────────
resource "azurerm_container_app" "fastapi" {
  name                         = var.aca_app_name
  container_app_environment_id = azurerm_container_app_environment.main.id
  resource_group_name          = var.resource_group_name
  revision_mode                = "Single"
  tags                         = var.tags

  identity {
    type         = "UserAssigned"
    identity_ids = [azurerm_user_assigned_identity.app.id]
  }

  registry {
    server   = var.acr_login_server
    identity = azurerm_user_assigned_identity.app.id
  }

  template {
    min_replicas = 1
    max_replicas = 5

    container {
      name   = "fastapi"
      image  = "${var.acr_login_server}/fastapi-app:${var.image_tag}"
      cpu    = 0.5
      memory = "1Gi"

      env {
        name  = "AZURE_CLIENT_ID"
        value = azurerm_user_assigned_identity.app.client_id
      }

      # Secret reference — value pulled from Key Vault by the app at runtime
      env {
        name        = "APP_SECRET"
        secret_name = "app-secret"
      }
    }
  }

  secret {
    name  = "app-secret"
    # In production: reference a Key Vault secret via identity
    # value = "@Microsoft.KeyVault(SecretUri=${var.key_vault_secret_uri})"
    value = "placeholder-replaced-by-keyvault"
  }

  ingress {
    external_enabled = false   # internal only — not exposed to internet
    target_port      = 8000
    transport        = "http"

    traffic_weight {
      latest_revision = true
      percentage      = 100
    }
  }

  depends_on = [
    azurerm_role_assignment.acr_pull,
    azurerm_role_assignment.kv_secrets_user,
    azurerm_role_assignment.storage_blob,
  ]
}
