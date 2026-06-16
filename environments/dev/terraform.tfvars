# environments/dev/terraform.tfvars

location            = "westeurope"
resource_group_name = "rg-usecase-private-dev"

acr_name             = "acrvisiumucdev001"
key_vault_name       = "kv-usecase-private-dev"
storage_account_name = "stusecasemediadev001"
aca_env_name         = "cae-usecase-private-dev"
aca_app_name         = "ca-fastapi-usecase-dev"

# Dev allows clean destroy/recreate during development
purge_protection_enabled = false

tags = {
  project     = "visium-usecase"
  environment = "dev"
  managed_by  = "terraform"
}
