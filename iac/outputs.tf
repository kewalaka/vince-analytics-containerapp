output "vince_url" {
  value = "https://${local.container_vince_app.azure_name}.${module.container_app_environment.default_domain}"
}
