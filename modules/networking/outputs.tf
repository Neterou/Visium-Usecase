output "vnet_id"       { value = azurerm_virtual_network.spoke.id }
output "aca_subnet_id" { value = azurerm_subnet.aca.id }
output "pe_subnet_id"  { value = azurerm_subnet.pe.id }
output "misc_subnet_id"{ value = azurerm_subnet.misc.id }
