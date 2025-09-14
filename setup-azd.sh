#!/bin/bash
# Quick setup script for Azure Developer CLI deployment

set -e

echo "=== Vince Analytics - Azure Developer CLI Setup ==="
echo ""

# Check prerequisites
echo "Checking prerequisites..."

if ! command -v az >/dev/null 2>&1; then
    echo "❌ Azure CLI is not installed. Please install it first:"
    echo "   https://docs.microsoft.com/en-us/cli/azure/install-azure-cli"
    exit 1
fi
echo "✅ Azure CLI found"

if ! command -v azd >/dev/null 2>&1; then
    echo "❌ Azure Developer CLI is not installed. Please install it first:"
    echo "   https://learn.microsoft.com/en-us/azure/developer/azure-developer-cli/install-azd"
    exit 1
fi
echo "✅ Azure Developer CLI found"

# Check if logged in to Azure
if ! az account show >/dev/null 2>&1; then
    echo "⚠️  Not logged in to Azure. Please run: az login"
    read -p "Would you like to login now? (y/n): " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        az login
    else
        echo "Please run 'az login' and then re-run this script."
        exit 1
    fi
fi
echo "✅ Logged in to Azure"

# Get current subscription
SUBSCRIPTION=$(az account show --query name -o tsv)
echo "📋 Current subscription: $SUBSCRIPTION"

read -p "Is this the correct subscription? (y/n): " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo "Please switch to the correct subscription using:"
    echo "   az account set --subscription <subscription-id-or-name>"
    echo "Then re-run this script."
    exit 1
fi

# Get environment name
echo ""
read -p "Enter environment name (default: dev): " ENV_NAME
ENV_NAME=${ENV_NAME:-dev}

# Get location
echo ""
echo "Common Azure locations:"
echo "  - australiaeast (Australia East)"
echo "  - eastus (East US)"
echo "  - westeurope (West Europe)"
echo "  - uksouth (UK South)"
echo ""
read -p "Enter Azure location (default: australiaeast): " LOCATION
LOCATION=${LOCATION:-australiaeast}

# Get location short code
read -p "Enter location short code (default: nzn): " LOCATION_SHORT
LOCATION_SHORT=${LOCATION_SHORT:-nzn}

# Get owner
read -p "Enter owner name: " OWNER

# Initialize azd if not already done
if [ ! -d ".azure/$ENV_NAME" ]; then
    echo ""
    echo "Initializing Azure Developer CLI environment..."
    azd init --environment $ENV_NAME
fi

# Update environment configuration
echo ""
echo "Updating environment configuration..."
ENV_FILE=".azure/$ENV_NAME/.env"

# Backup existing .env if it exists
if [ -f "$ENV_FILE" ]; then
    cp "$ENV_FILE" "$ENV_FILE.backup"
fi

# Create/update .env file
cat > "$ENV_FILE" << EOF
AZURE_LOCATION=$LOCATION
AZURE_LOCATION_SHORT=$LOCATION_SHORT
AZURE_RESOURCE_GROUP=rg-vince-analytics-containerapp-$ENV_NAME
OWNER=$OWNER
EOF

echo "✅ Environment configuration updated"
echo ""
echo "Configuration saved to: $ENV_FILE"
echo "Resource Group will be: rg-vince-analytics-containerapp-$ENV_NAME"
echo ""
echo "=== Next Steps ==="
echo ""
echo "1. Review the configuration in: $ENV_FILE"
echo "2. Run 'azd up' to deploy your Vince Analytics instance"
echo "3. After deployment, access your app using the provided URL"
echo ""
echo "For more information, see:"
echo "  - AZD.md for detailed Azure Developer CLI usage"
echo "  - RESOURCE_GROUPS.md for resource group management"
echo "  - README.md for general deployment information"
echo ""
echo "Ready to deploy! Run: azd up"