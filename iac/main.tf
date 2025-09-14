data "azurerm_client_config" "current" {}

data "azurerm_resource_group" "this" {
  name = local.resource_group_name
}

resource "azurerm_log_analytics_workspace" "this" {
  name                = local.log_analytics_workspace_name
  location            = data.azurerm_resource_group.this.location
  resource_group_name = data.azurerm_resource_group.this.name
  sku                 = "PerGB2018"

  retention_in_days = 30

  tags = local.default_tags
}

module "container_app_environment" {
  source  = "Azure/avm-res-app-managedenvironment/azurerm"
  version = "0.3.0"

  name                = local.container_app_environment_name
  resource_group_name = data.azurerm_resource_group.this.name
  location            = data.azurerm_resource_group.this.location

  log_analytics_workspace = { resource_id = azurerm_log_analytics_workspace.this.id }

  storages = local.storage_definitions

  tags = local.default_tags

  # zone redundancy must be disabled unless we supply a subnet for vnet integration.
  zone_redundancy_enabled = false
}

module "container_apps" {
  for_each = local.container_definitions

  source  = "Azure/avm-res-app-containerapp/azurerm"
  version = "0.7.4"

  container_app_environment_resource_id = module.container_app_environment.id
  name                                  = each.value.azure_name
  resource_group_name                   = data.azurerm_resource_group.this.name
  location                              = data.azurerm_resource_group.this.location
  revision_mode                         = "Single"

  template = {
    containers = [
      {
        name   = each.value.name
        memory = each.value.memory
        cpu    = each.value.cpu
        image  = each.value.image

        env = concat(
          [for k, v in each.value.env_vars : {
            name  = k
            value = v
          }],
          [for k, v in each.value.secrets : {
            name        = k
            secret_name = v
          }]
        )

        volume_mounts = each.value.volume_mounts
        command       = try(each.value.command, null)
        args          = try(each.value.args, null)
      }
    ]
    init_containers = [
      for init_container in try(each.value.init_containers, []) : {
        name   = init_container.name
        cpu    = init_container.cpu
        image  = init_container.image
        memory = init_container.memory

        env = concat(
          [for k, v in try(init_container.env_vars, {}) : {
            name  = k
            value = v
          }],
          [for k, v in try(init_container.secrets, {}) : {
            name        = k
            secret_name = v
          }]
        )

        volume_mounts = try(init_container.volume_mounts, [])
        command       = try(init_container.command, null)
        args          = try(init_container.args, null)
      }
    ]

    min_replicas = try(each.value.min_replicas, 0)
    max_replicas = try(each.value.max_replicas, 10)

    volumes = each.value.volumes
  }

  ingress = each.value.ingress

  managed_identities = {
    system_assigned = true
  }

  # Only include secrets that this container actually needs - derive from secrets block
  secrets = {
    for secret_key, secret_def in local.secret_definitions :
    secret_key => secret_def
    if contains([for secret_name in values(each.value.secrets) : secret_name], secret_def.name)
  }

  tags = local.default_tags
}

# Grant each Container App access to Key Vault
resource "azurerm_role_assignment" "container_app_keyvault_access" {
  for_each = local.container_definitions

  scope                = module.keyvault.resource_id
  role_definition_name = "Key Vault Secrets User"
  principal_id         = module.container_apps[each.key].identity[0].principal_id
}
