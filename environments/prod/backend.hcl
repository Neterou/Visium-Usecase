# Backend configuration for the prod environment.
# Note the different key — prod has its own state file, fully isolated from dev.
# Passed to terraform init via:
#   terraform init -backend-config=environments/prod/backend.hcl

resource_group_name  = "rg-tfstate"
storage_account_name = "stgtfstate001"
container_name       = "tfstate"
key                  = "visium-usecase-prod.tfstate"
