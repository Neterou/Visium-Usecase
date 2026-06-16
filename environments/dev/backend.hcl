# Backend configuration for the dev environment.
# Passed to terraform init via:
#   terraform init -backend-config=environments/dev/backend.hcl

resource_group_name  = "rg-tfstate"
storage_account_name = "stgtfstate001"
container_name       = "tfstate"
key                  = "visium-usecase-dev.tfstate"
