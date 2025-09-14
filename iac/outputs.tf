output "vince_url" {
  value = "https://${local.container_vince_app.azure_name}.${module.container_app_environment.default_domain}"
}

output "keyvault_name" {
  description = "Name of the Key Vault containing admin credentials"
  value       = module.keyvault.name
}

output "admin_username" {
  description = "Admin username for Vince Analytics"
  value       = local.container_vince_app.env_vars.VINCE_ADMIN_NAME
}

output "resource_group_name" {
  description = "Name of the resource group"
  value       = data.azurerm_resource_group.this.name
}
