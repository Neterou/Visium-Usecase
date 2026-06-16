# ── VNet ──────────────────────────────────────────────────────────────────────
resource "azurerm_virtual_network" "spoke" {
  name                = var.vnet_name
  location            = var.location
  resource_group_name = var.resource_group_name
  address_space       = var.vnet_address_space
  tags                = var.tags
}

# ── Subnets ───────────────────────────────────────────────────────────────────

# /26 → 64 IPs for Container Apps Environment (requires dedicated subnet)
resource "azurerm_subnet" "aca" {
  name                 = "snet-aca"
  resource_group_name  = var.resource_group_name
  virtual_network_name = azurerm_virtual_network.spoke.name
  address_prefixes     = ["10.0.0.0/26"]

  delegation {
    name = "aca-delegation"
    service_delegation {
      name = "Microsoft.App/environments"
      actions = [
        "Microsoft.Network/virtualNetworks/subnets/join/action"
      ]
    }
  }
}

# /27 → 32 IPs for Private Endpoints (Key Vault, Storage)
resource "azurerm_subnet" "pe" {
  name                 = "snet-pe"
  resource_group_name  = var.resource_group_name
  virtual_network_name = azurerm_virtual_network.spoke.name
  address_prefixes     = ["10.0.0.64/27"]

  private_endpoint_network_policies = "Disabled"
}

# /28 → 16 IPs for misc services (ACR PE, future)
resource "azurerm_subnet" "misc" {
  name                 = "snet-misc"
  resource_group_name  = var.resource_group_name
  virtual_network_name = azurerm_virtual_network.spoke.name
  address_prefixes     = ["10.0.0.96/28"]

  private_endpoint_network_policies = "Disabled"
}

# ── NSGs ──────────────────────────────────────────────────────────────────────

resource "azurerm_network_security_group" "aca" {
  name                = "nsg-snet-aca"
  location            = var.location
  resource_group_name = var.resource_group_name
  tags                = var.tags

  # Allow inbound from hub (VPN users on company network only)
  security_rule {
    name                       = "allow-vpn-inbound"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_ranges    = ["80", "443"]
    source_address_prefix      = "VirtualNetwork"
    destination_address_prefix = "10.0.0.0/26"
  }

  # Deny all other inbound internet traffic
  security_rule {
    name                       = "deny-internet-inbound"
    priority                   = 900
    direction                  = "Inbound"
    access                     = "Deny"
    protocol                   = "*"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = "Internet"
    destination_address_prefix = "*"
  }
}

resource "azurerm_network_security_group" "pe" {
  name                = "nsg-snet-pe"
  location            = var.location
  resource_group_name = var.resource_group_name
  tags                = var.tags

  # Only allow traffic from ACA subnet to reach Private Endpoints
  security_rule {
    name                       = "allow-aca-to-pe"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = "10.0.0.0/26"
    destination_address_prefix = "10.0.0.64/27"
  }

  security_rule {
    name                       = "deny-all-inbound"
    priority                   = 900
    direction                  = "Inbound"
    access                     = "Deny"
    protocol                   = "*"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
}

# ── NSG Associations ──────────────────────────────────────────────────────────
resource "azurerm_subnet_network_security_group_association" "aca" {
  subnet_id                 = azurerm_subnet.aca.id
  network_security_group_id = azurerm_network_security_group.aca.id
}

resource "azurerm_subnet_network_security_group_association" "pe" {
  subnet_id                 = azurerm_subnet.pe.id
  network_security_group_id = azurerm_network_security_group.pe.id
}

# ── VNet Peering (spoke → hub) ────────────────────────────────────────────────
resource "azurerm_virtual_network_peering" "spoke_to_hub" {
  name                      = "peer-spoke-to-hub"
  resource_group_name       = var.resource_group_name
  virtual_network_name      = azurerm_virtual_network.spoke.name
  remote_virtual_network_id = var.hub_vnet_id

  allow_virtual_network_access = true
  allow_forwarded_traffic      = true
  allow_gateway_transit        = false
  use_remote_gateways          = true   # use hub VPN gateway for on-prem traffic
}
