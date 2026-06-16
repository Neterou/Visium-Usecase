# Visium DevOps Use Case — Azure Infrastructure

Private FastAPI deployment on Azure Container Apps with full network isolation.

## Architecture

- **Spoke VNet** `vnet-usecase-private-01` (10.0.0.0/24) peered to hub
- **Azure Container Apps** (VNet-injected, internal load balancer only)
- **Key Vault** + **Storage Account** — no public access, reachable via Private Endpoints
- **Managed Identity** for all service-to-service auth (no passwords, no secrets in code)
- App reachable only by users connected to the company network via VPN

## Repo Structure

```
.
├── main.tf                  # Root module — wires all modules together
├── variables.tf
├── outputs.tf
├── modules/
│   ├── networking/          # VNet, subnets, NSGs, VNet peering
│   ├── container_apps/      # ACA environment, app, managed identity, RBAC
│   ├── keyvault/            # Key Vault + Private Endpoint
│   ├── storage/             # Storage Account + Private Endpoint
│   └── acr/                 # Azure Container Registry
├── environments/
│   └── dev/
│       └── terraform.tfvars # Non-sensitive env-specific values
└── .github/
    └── workflows/
        └── terraform.yml    # GitOps CI/CD — plan on PR, apply on merge
```

## GitOps Flow

```
PR opened  →  terraform plan  →  output posted as PR comment
PR merged  →  terraform apply  →  (optional approval gate via GitHub Environments)
```

No manual `terraform apply` ever. The pipeline's Service Principal authenticates
via OIDC federated credentials — no client secrets stored anywhere.

## Terraform State

Remote backend on Azure Blob Storage:
- Storage Account: `stgtfstate001` (pre-provisioned, outside this project)
- Container: `tfstate`
- Key: `visium-usecase.tfstate`
- Locking: Azure Blob lease (built-in, no extra tooling)

## Sensitive Variables (GitHub Actions Secrets)

| Secret | Description |
|--------|-------------|
| `AZURE_CLIENT_ID` | Service Principal (federated OIDC) |
| `AZURE_TENANT_ID` | Azure AD tenant |
| `AZURE_SUBSCRIPTION_ID` | Target subscription |
| `HUB_VNET_ID` | Resource ID of existing hub VNet |
| `KV_PRIVATE_DNS_ZONE_ID` | Resource ID of hub Private DNS Zone for Key Vault |
| `STORAGE_PRIVATE_DNS_ZONE_ID` | Resource ID of hub Private DNS Zone for Storage |

## RBAC — Least Privilege

| Identity | Role | Scope |
|----------|------|-------|
| App Managed Identity | AcrPull | ACR |
| App Managed Identity | Key Vault Secrets User | Key Vault |
| App Managed Identity | Storage Blob Data Contributor | Storage Account |
| GitHub Actions SP | Contributor | Resource Group |
| GitHub Actions SP | Storage Blob Data Contributor | TF State Storage Account |
