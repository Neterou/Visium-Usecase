# environments/prod/terraform.tfvars
# Production environment values.

location            = "westeurope"
resource_group_name = "rg-usecase-private-prod"

acr_name             = "acrvisiumucprod001"
key_vault_name       = "kv-usecase-private-prod"
storage_account_name = "stusecasemediaprod001"
aca_env_name         = "cae-usecase-private-prod"
aca_app_name         = "ca-fastapi-usecase-prod"

# Prod: compliance + data safety. Once enabled, cannot be disabled.
purge_protection_enabled = true

tags = {
  project     = "visium-usecase"
  environment = "prod"
  managed_by  = "terraform"
}
