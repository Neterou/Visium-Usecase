variable "resource_group_name"        { type = string }
variable "location"                    { type = string }
variable "tags"                        { type = map(string) }
variable "key_vault_name"              { type = string }
variable "tenant_id"                   { type = string }
variable "private_endpoint_subnet_id"  { type = string }
variable "private_dns_zone_id"         { type = string }

variable "purge_protection_enabled" {
  description = "Enable Key Vault purge protection. Irreversible once enabled. True for prod, false for dev."
  type        = bool
}
