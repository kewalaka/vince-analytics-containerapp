locals {
  appname        = "vince-analytics-containerapp"
  default_suffix = "${local.appname}-${var.env_code}"

  # optional computed short name
  # this assume two letters for the resource type, three for the location, and three for the environment code (= 24 chars max)
  short_appname        = substr(replace(local.appname, "-", ""), 0, 16)
  default_short_suffix = "${local.short_appname}${var.env_code}"

  # add resource names here, using CAF-aligned naming conventions
  resource_group_name            = "rg-${local.default_suffix}"
  storage_account_name           = "st${local.default_short_suffix}"
  keyvault_name                  = "kv${local.default_short_suffix}"
  container_app_environment_name = "cae-${local.default_suffix}"
  log_analytics_workspace_name   = "law-${local.default_suffix}"

  default_tags = merge(
    var.default_tags,
    tomap({
      "Environment"  = var.env_code
      "LocationCode" = var.short_location_code
    })
  )
}

locals {
  secret_definitions = {
    vince_admin_password = {
      name                = "vince-admin-password"
      key_vault_secret_id = azurerm_key_vault_secret.vince_admin_password.versionless_id
      identity            = "system"
    }
  }

  container_definitions = {
    app = local.container_vince_app
  }

  # Derive storage definitions from all container definitions
  storage_definitions = {
    for storage_name in distinct(flatten([
      for container_key, container in local.container_definitions : [
        for volume in try(container.volumes, []) :
        volume.storage_name if volume.storage_type == "AzureFile"
      ]
      ])) : storage_name => {
      account_name = module.storage_account.name
      share_name   = storage_name
      access_key   = module.storage_account.resource.primary_access_key
      access_mode  = "ReadWrite"
    }
  }
}
