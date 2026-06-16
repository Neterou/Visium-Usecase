# environments/dev/terraform.tfvars
# These values are non-sensitive. Sensitive vars (tenant_id, hub IDs)
# are injected as GitHub Actions secrets at runtime.

location            = "westeurope"
resource_group_name = "rg-usecase-private-dev"

acr_name             = "acrvisiumucdev001"
key_vault_name       = "kv-usecase-private-dev"
storage_account_name = "stusecasemediadev001"
aca_env_name         = "cae-usecase-private-dev"
aca_app_name         = "ca-fastapi-usecase-dev"

tags = {
  project     = "visium-usecase"
  environment = "dev"
  managed_by  = "terraform"
}
