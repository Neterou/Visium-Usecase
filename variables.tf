variable "location" {
  description = "Azure region for all resources"
  type        = string
  default     = "westeurope"
}

variable "resource_group_name" {
  description = "Name of the main resource group"
  type        = string
  default     = "rg-usecase-private-01"
}

variable "tags" {
  description = "Common tags applied to all resources"
  type        = map(string)
  default = {
    project     = "visium-usecase"
    environment = "dev"
    managed_by  = "terraform"
  }
}

variable "tenant_id" {
  description = "Azure AD tenant ID"
  type        = string
}

# ── Hub networking (existing infrastructure) ──────────────────────────────────
variable "hub_vnet_id" {
  description = "Resource ID of the existing hub VNet to peer with"
  type        = string
}

variable "keyvault_private_dns_zone_id" {
  description = "Resource ID of the existing Private DNS Zone for Key Vault (in hub)"
  type        = string
}

variable "storage_private_dns_zone_id" {
  description = "Resource ID of the existing Private DNS Zone for Storage (in hub)"
  type        = string
}

# ── Resource names ─────────────────────────────────────────────────────────────
variable "acr_name" {
  description = "Name of the Azure Container Registry (globally unique, alphanumeric)"
  type        = string
  default     = "acrvisiumusecase001"
}

variable "key_vault_name" {
  description = "Name of the Key Vault (globally unique)"
  type        = string
  default     = "kv-usecase-private-01"
}

variable "storage_account_name" {
  description = "Name of the Storage Account (globally unique)"
  type        = string
  default     = "stusecasemedia001"
}

variable "aca_env_name" {
  description = "Name of the Container Apps Environment"
  type        = string
  default     = "cae-usecase-private-01"
}

variable "aca_app_name" {
  description = "Name of the Container App"
  type        = string
  default     = "ca-fastapi-usecase"
}

variable "image_tag" {
  description = "Docker image tag to deploy (injected by CI/CD pipeline)"
  type        = string
  default     = "latest"
}
