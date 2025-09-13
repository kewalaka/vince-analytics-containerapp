locals {
  container_vince_app = {
    name         = "vince"
    azure_name   = "ca-vince-app-${var.env_code}"
    image        = "ghcr.io/vinceanalytics/vince:v1.11.8"
    cpu          = 0.5
    memory       = "1Gi"
    max_replicas = 1
    min_replicas = 0
    env_vars = {
      VINCE_LISTEN     = ":8080"
      VINCE_DATA       = "/data"
      VINCE_ADMIN_NAME = "vince@admin.local"
      VINCE_URL        = "https://ca-vince-app-${var.env_code}.${module.container_app_environment.default_domain}"
    }
    secrets = {
      VINCE_ADMIN_PASSWORD = "vince-admin-password"
    }
    volume_mounts = [
      {
        name = "vince-data"
        path = "/data"
      }
    ]
    volumes = [
      {
        name         = "vince-data"
        storage_type = "AzureFile"
        storage_name = "vince-data"
      }
    ]
    required_secrets = ["vince_admin_password"]
    args             = ["serve"]
    ports = [
      {
        port      = 8080
        transport = "http"
      }
    ]
    ingress = {
      target_port      = 8080
      external_enabled = true
      transport        = "http"
      traffic_weight = [
        {
          percentage      = 100
          latest_revision = true
        }
      ]
    }
  }
}
