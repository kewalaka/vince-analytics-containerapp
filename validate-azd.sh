#!/bin/bash
# Validation script for azd configuration

set -e

echo "=== Validating Azure Developer CLI Configuration ==="
echo ""

# Check if we're in the right directory
if [ ! -f "azure.yaml" ]; then
    echo "Error: azure.yaml not found. Please run this script from the repository root."
    exit 1
fi

echo "✓ azure.yaml found"

# Check required directories and files
REQUIRED_FILES=(
    ".azure/config.json"
    ".azd/hooks/preprovision.sh"
    ".azd/hooks/postprovision.sh"
    ".azd/next-steps.json"
    "iac/main.tf"
    "iac/variables.tf"
    "iac/outputs.tf"
    "iac/main.tfvars.json"
    "AZD.md"
    "RESOURCE_GROUPS.md"
    "validate-azd.sh"
    "setup-azd.sh"
)

for file in "${REQUIRED_FILES[@]}"; do
    if [ -f "$file" ]; then
        echo "✓ $file exists"
    else
        echo "✗ $file missing"
        exit 1
    fi
done

# Check if hook scripts are executable
if [ -x ".azd/hooks/preprovision.sh" ]; then
    echo "✓ preprovision.sh is executable"
else
    echo "✗ preprovision.sh is not executable"
    exit 1
fi

if [ -x ".azd/hooks/postprovision.sh" ]; then
    echo "✓ postprovision.sh is executable"
else
    echo "✗ postprovision.sh is not executable"
    exit 1
fi

# Validate azure.yaml syntax (basic check)
if command -v yq >/dev/null 2>&1; then
    yq eval . azure.yaml >/dev/null && echo "✓ azure.yaml syntax is valid"
else
    echo "! yq not available, skipping azure.yaml syntax validation"
fi

# Check if main.tfvars.json is valid JSON
if command -v jq >/dev/null 2>&1; then
    jq . iac/main.tfvars.json >/dev/null && echo "✓ main.tfvars.json is valid JSON"
else
    echo "! jq not available, skipping JSON validation"
fi

echo ""
echo "=== Configuration Summary ==="
echo "Azure DevCli support has been added with:"
echo "  • azure.yaml configuration file"
echo "  • Terraform integration in iac/ directory"
echo "  • Pre/post-provisioning hooks"
echo "  • Environment configuration template"
echo "  • Comprehensive documentation in AZD.md"
echo ""
echo "Next steps:"
echo "  1. Install Azure Developer CLI: https://learn.microsoft.com/en-us/azure/developer/azure-developer-cli/install-azd"
echo "  2. Run 'azd init' to initialize your environment"
echo "  3. Configure environment variables in .azure/<env>/.env"
echo "  4. Run 'azd up' to deploy"
echo ""
echo "Validation complete ✓"