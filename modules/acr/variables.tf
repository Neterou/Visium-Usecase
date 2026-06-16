variable "resource_group_name" { type = string }
variable "location"            { type = string }
variable "tags"                { type = map(string) }
variable "acr_name"            { type = string }

variable "private_endpoint_subnet_id" {
  description = "Subnet ID for the ACR Private Endpoint"
  type        = string
}

variable "private_dns_zone_id" {
  description = "Resource ID of the existing Private DNS Zone for ACR (privatelink.azurecr.io) in hub"
  type        = string
}
