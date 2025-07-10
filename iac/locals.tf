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

  # tflint-ignore: terraform_unused_declarations
  location = data.azurerm_resource_group.this.location

  # tflint-ignore: terraform_unused_declarations
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
}
