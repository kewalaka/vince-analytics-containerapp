# Vince Analytics on Azure Container Apps

This Terraform configuration deploys [Vince Analytics](https://www.vinceanalytics.com/) on Azure Container Apps. Vince is a privacy-focused, self-hosted web analytics solution that's simpler and lighter than alternatives like Plausible Analytics (on which it is based) and Matomo.

## Architecture

- **Azure Container Apps**: Hosts the Vince analytics application
- **Azure File Storage**: Persistent storage for Vince data
- **Azure Key Vault**: Stores admin credentials securely
- **Init Container**: Creates the admin user before the main application starts

## Key Features

- Single container deployment (no database required)
- Automatic admin user creation via init container
- Persistent data storage using Azure Files
- Secure credential management with Key Vault
- Auto-scaling with Container Apps

## Deployment

1. Ensure you have a resource group created
2. Update `environments/dev.terraform.tfvars` with your desired values
3. Deploy:

```bash
cd iac
terraform init
terraform plan -var-file="environments/dev.terraform.tfvars"
terraform apply -var-file="environments/dev.terraform.tfvars"
```

## Configuration

The application is configured with:

- Data stored in `/data` directory (mapped to Azure File share)
- Admin user created automatically on first deployment
- External access enabled on port 8080
- Default URL pattern: `https://ca-vince-app-{env}.{location}.azurecontainerapps.io`

## Admin Access

After deployment, you can access the Vince interface using:

- **URL**: Output from `vince_url`
- **Username**: `admin@vince.local`
- **Password**: Retrieved from Key Vault (secret: `vince-admin-password`)

## Environment Variables

Key Vince environment variables are configured automatically:

- `VINCE_LISTEN`: `:8080`
- `VINCE_DATA`: `/data`
- `VINCE_URL`: Auto-generated based on Container App FQDN
- `VINCE_ADMIN_NAME`: From Key Vault
- `VINCE_ADMIN_PASSWORD`: From Key Vault

## Testing locally

```sh
# create a local data dir for testing
mkdir -p ./local-data

# run the container (adjust VINCE_ADMIN_PASSWORD to a test value)
docker run --rm \
  -e VINCE_LISTEN=":8080" \
  -e VINCE_DATA="/data" \
  -e VINCE_ADMIN_NAME="vince@admin.local" \
  -e VINCE_ADMIN_PASSWORD="test-pass" \
  -p 8080:8080 \
  -v "$(pwd)/local-data:/data" \
  ghcr.io/vinceanalytics/vince:v1.11.8 serve
```
