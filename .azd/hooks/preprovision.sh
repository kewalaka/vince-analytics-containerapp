#!/bin/bash
set -e

echo "Pre-provisioning: Validating Terraform configuration..."

cd iac

# Check if terraform.tfvars exists, if not create from template
if [ ! -f terraform.tfvars ]; then
    if [ -f environments/dev.terraform.tfvars ]; then
        echo "Creating terraform.tfvars from dev template..."
        cp environments/dev.terraform.tfvars terraform.tfvars
    else
        echo "Warning: No terraform.tfvars found. Using default values."
    fi
fi

# Ensure resource group exists if AZURE_RESOURCE_GROUP is set
if [ -n "$AZURE_RESOURCE_GROUP" ] && [ -n "$AZURE_LOCATION" ]; then
    echo "Checking if resource group '$AZURE_RESOURCE_GROUP' exists..."
    if ! az group show --name "$AZURE_RESOURCE_GROUP" >/dev/null 2>&1; then
        echo "Creating resource group '$AZURE_RESOURCE_GROUP' in '$AZURE_LOCATION'..."
        az group create --name "$AZURE_RESOURCE_GROUP" --location "$AZURE_LOCATION"
        echo "Resource group created successfully."
    else
        echo "Resource group '$AZURE_RESOURCE_GROUP' already exists."
    fi
fi

echo "Initializing Terraform..."
terraform init

echo "Validating Terraform configuration..."
terraform validate

echo "Pre-provisioning complete."