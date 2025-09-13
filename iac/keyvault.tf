ephemeral "random_password" "vince_admin_password" {
  length           = 24
  override_special = "!#$%&*()-_=+[]{}<>:?"
}

module "keyvault" {
  source  = "Azure/avm-res-keyvault-vault/azurerm"
  version = "0.10.0"

  resource_group_name = data.azurerm_resource_group.this.name
  location            = data.azurerm_resource_group.this.location
  tenant_id           = data.azurerm_client_config.current.tenant_id

  name = local.keyvault_name

  sku_name                 = "standard"
  purge_protection_enabled = false
  network_acls = {
    default_action = "Allow"
    bypass         = "AzureServices"
  }

  role_assignments = {
    "terraform-keyvault-access" = {
      principal_id               = data.azurerm_client_config.current.object_id
      role_definition_id_or_name = "Key Vault Secrets Officer"
    }
  }

  tags = local.default_tags
}

resource "azurerm_key_vault_secret" "vince_admin_password" {
  name             = "vince-admin-password"
  value_wo         = ephemeral.random_password.vince_admin_password.result
  value_wo_version = 3
  key_vault_id     = module.keyvault.resource_id
}
