output "vince_url" {
  value = "https://${local.container_vince_app.azure_name}.${var.short_location_code}.azurecontainerapps.io"
}
