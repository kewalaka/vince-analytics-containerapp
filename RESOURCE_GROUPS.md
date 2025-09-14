# Resource Group Setup

The Vince Analytics deployment requires an existing Azure Resource Group. You have two options:

## Option 1: Create Resource Group with azd

Let azd manage the resource group for you (recommended for new deployments):

```bash
# This will be handled automatically by azd
azd up
```

## Option 2: Use Existing Resource Group

If you want to use an existing resource group:

1. Create or identify your resource group:
```bash
az group create --name rg-vince-analytics-containerapp-dev --location australiaeast
```

2. Update your azd environment configuration:
```bash
# Set the resource group name in your environment
azd env set AZURE_RESOURCE_GROUP rg-vince-analytics-containerapp-dev
```

3. Deploy:
```bash
azd up
```

## Environment-Specific Resource Groups

For multiple environments (dev, staging, prod), use naming conventions:

```bash
# Development
az group create --name rg-vince-analytics-containerapp-dev --location australiaeast

# Staging  
az group create --name rg-vince-analytics-containerapp-staging --location australiaeast

# Production
az group create --name rg-vince-analytics-containerapp-prod --location australiaeast
```

Then switch between environments:
```bash
azd env select dev
azd env set AZURE_RESOURCE_GROUP rg-vince-analytics-containerapp-dev
azd up

azd env select staging  
azd env set AZURE_RESOURCE_GROUP rg-vince-analytics-containerapp-staging
azd up
```