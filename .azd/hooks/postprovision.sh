#!/bin/bash
set -e

echo "Post-provisioning: Extracting deployment outputs..."

cd iac

# Extract key outputs for user reference
if terraform output -json > /tmp/tf_outputs.json 2>/dev/null; then
    echo ""
    echo "=== Deployment Complete ==="
    echo ""
    
    if command -v jq >/dev/null 2>&1; then
        # If jq is available, format the output nicely
        VINCE_URL=$(jq -r '.vince_url.value // "N/A"' /tmp/tf_outputs.json)
        echo "Vince Analytics URL: $VINCE_URL"
        echo ""
        echo "Admin Login Details:"
        echo "  Username: vince@admin.local"
        echo "  Password: (stored in Azure Key Vault secret 'vince-admin-password')"
        echo ""
        echo "To retrieve the admin password, run:"
        echo "  az keyvault secret show --name vince-admin-password --vault-name \$(terraform output -raw keyvault_name) --query value -o tsv"
    else
        # Fallback if jq is not available
        echo "Deployment outputs:"
        terraform output
    fi
    
    rm -f /tmp/tf_outputs.json
else
    echo "Unable to retrieve Terraform outputs. Check deployment status."
fi

echo ""
echo "Post-provisioning complete."