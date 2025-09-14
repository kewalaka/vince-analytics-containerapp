# Deploying with Azure Developer CLI (azd)

This repository now supports the [Azure Developer CLI (azd)](https://learn.microsoft.com/en-us/azure/developer/azure-developer-cli/) for simplified deployment to Azure.

## Prerequisites

1. [Azure Developer CLI](https://learn.microsoft.com/en-us/azure/developer/azure-developer-cli/install-azd) installed
2. Azure CLI authenticated (`az login`)
3. An Azure subscription with appropriate permissions

## Quick Start

### Automated Setup (Recommended)

Use the provided setup script for guided configuration:

```bash
./setup-azd.sh
```

This script will:
- Check prerequisites (Azure CLI, azd)  
- Verify Azure login status
- Create azd environment configuration
- Set up environment variables
- Provide next steps

### Manual Setup

### 1. Initialize the environment

```bash
# Initialize azd environment (first time only)
azd init

# Follow the prompts to configure:
# - Environment name (e.g., "dev", "prod")  
# - Azure subscription
# - Azure region
```

### 2. Configure environment variables

Edit the `.azure/<env-name>/.env` file to set:

```bash
AZURE_LOCATION=australiaeast
AZURE_LOCATION_SHORT=nzn
AZURE_RESOURCE_GROUP=rg-vince-analytics-containerapp-dev
OWNER=YourName
```

> **Note**: The resource group will be created automatically if it doesn't exist. See [RESOURCE_GROUPS.md](RESOURCE_GROUPS.md) for more details on resource group management.

### 3. Deploy to Azure

```bash
# Deploy infrastructure and application
azd up
```

This will:
- Provision all Azure resources using the existing Terraform configuration
- Create the Vince Analytics container app
- Set up persistent storage and Key Vault
- Display the application URL and admin credentials

### 4. Access your deployment

After deployment completes, you'll see:
- **Application URL**: Where your Vince Analytics instance is running
- **Admin Username**: `vince@admin.local` 
- **Admin Password**: Stored in Azure Key Vault

Retrieve the admin password:
```bash
az keyvault secret show --name vince-admin-password --vault-name $(azd env get-values | grep AZURE_KEY_VAULT_NAME | cut -d= -f2) --query value -o tsv
```

## Environment Management

### List environments
```bash
azd env list
```

### Switch environments
```bash
azd env select <environment-name>
```

### Create new environment
```bash
azd env new <environment-name>
```

### Deploy to different environment
```bash
azd env select production
azd up
```

## Cleanup

Remove all resources:
```bash
azd down
```

## Terraform Integration

The azd configuration uses the existing Terraform infrastructure in the `iac/` directory. The deployment process:

1. **Pre-provision**: Validates Terraform configuration and initializes
2. **Provision**: Runs `terraform apply` with azd-generated variables
3. **Post-provision**: Displays deployment information and credentials

## Troubleshooting

### View deployment logs
```bash
azd provision --debug
```

### Check Terraform state
```bash
cd iac
terraform show
```

### Manual Terraform operations
You can still use Terraform directly:
```bash
cd iac
terraform plan -var-file="environments/dev.terraform.tfvars"
terraform apply -var-file="environments/dev.terraform.tfvars"
```

## Directory Structure

The azd integration maintains compatibility with the existing structure:

```
.
├── azure.yaml              # azd configuration
├── .azure/                 # azd environments
├── .azd/                   # azd hooks and scripts
├── iac/                    # Terraform infrastructure
│   ├── main.tf
│   ├── variables.tf
│   ├── outputs.tf
│   ├── main.tfvars.json    # azd variable mapping
│   └── environments/       # Environment-specific Terraform vars
├── README.md
└── AZD.md                  # This file
```

## What's Different from Direct Terraform?

- **Simplified Commands**: `azd up` instead of multiple Terraform commands
- **Environment Management**: Built-in environment switching and configuration
- **Integrated Auth**: Uses Azure CLI authentication automatically  
- **Consistent Variables**: Environment variables are automatically mapped to Terraform variables
- **Post-deployment Info**: Automatically displays URLs and credentials
- **GitHub Actions**: Ready-to-use CI/CD pipeline configuration

The underlying infrastructure remains identical - azd simply provides a better developer experience on top of the existing Terraform configuration.