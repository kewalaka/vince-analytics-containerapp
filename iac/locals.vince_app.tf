locals {
  container_vince_app = {
    name         = "vince"
    azure_name   = "ca-vince-app-${var.env_code}"
    image        = "ghcr.io/vinceanalytics/vince:latest"
    cpu          = 0.5
    memory       = "1Gi"
    max_replicas = 3
    min_replicas = 1
    env_vars = {
      VINCE_LISTEN     = ":8080"
      VINCE_DATA       = "/data"
      VINCE_ADMIN_NAME = "vince@admin.local"
      VINCE_URL        = "https://ca-vince-app-${var.env_code}.${var.short_location_code}.azurecontainerapps.io"
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
    command          = ["vince"]
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
    }
  }
}
