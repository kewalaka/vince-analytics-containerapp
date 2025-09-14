# Testing Azure Developer CLI Integration

This document provides a walkthrough for testing the azd implementation without actually deploying resources.

## Validation Testing

### 1. Run the validation script
```bash
./validate-azd.sh
```
Expected output: All checks should pass ✓

### 2. Test the setup script (dry run)
```bash
# Test prerequisites checking (will not modify anything if prereqs missing)  
./setup-azd.sh
```

### 3. Validate azure.yaml syntax
```bash
# If you have yq installed
yq eval . azure.yaml

# Manual check - ensure these sections exist:
# - name: vince-analytics-containerapp
# - infra.provider: terraform
# - infra.path: iac
# - services.web configuration
```

### 4. Validate Terraform variable mapping
```bash
cd iac
# Check the tfvars.json has correct variable substitution patterns
cat main.tfvars.json

# Expected patterns:
# $(AZURE_ENV_NAME) -> env_code
# $(AZURE_LOCATION_SHORT) -> short_location_code  
# $(OWNER) -> default_tags.Owner
```

### 5. Test hook scripts
```bash
# Check preprovision hook (will fail on terraform commands without terraform installed)
bash -n .azd/hooks/preprovision.sh  # syntax check only

# Check postprovision hook
bash -n .azd/hooks/postprovision.sh  # syntax check only
```

## Mock Deployment Flow

To test the full flow without deploying:

### 1. Environment Setup
```bash
# Create test environment config
mkdir -p .azure/test
cp .azure/dev/.env .azure/test/.env

# Edit the test environment values
sed -i 's/dev/test/g' .azure/test/.env
```

### 2. Variable Substitution Test
```bash
# Simulate azd environment variable injection
export AZURE_ENV_NAME=test
export AZURE_LOCATION_SHORT=nzn  
export OWNER=testuser

# Test variable substitution (requires envsubst)
if command -v envsubst >/dev/null 2>&1; then
    envsubst < iac/main.tfvars.json
    echo "✅ Variable substitution test passed"
else
    echo "ℹ️  Install gettext for envsubst to test variable substitution"
fi
```

### 3. Directory Structure Validation
```bash
# Verify expected azd directory structure
echo "Checking azd directory structure:"
tree -a -I '.git' . | grep -E '\.(yaml|json|sh|env)$'

# Expected structure:
# azure.yaml (root)
# .azure/config.json
# .azure/dev/.env  
# .azd/hooks/*.sh
# .azd/next-steps.json
# iac/main.tfvars.json
```

## Integration Points

### azd → Terraform Variable Flow
```
azd environment variables:
AZURE_ENV_NAME=dev
AZURE_LOCATION_SHORT=nzn
OWNER=testuser

↓ (via main.tfvars.json)

Terraform variables:
env_code = "dev"
short_location_code = "nzn" 
default_tags = {
  "azd-env-name" = "dev"
  "azd-template" = "vince-analytics-containerapp"
  "Owner" = "testuser"
}
```

### Resource Naming Pattern
```
Input: env_code="dev", short_location_code="nzn"
Output:
- Resource Group: rg-vince-analytics-containerapp-dev
- Storage Account: stvinceanalyticscontaine + dev  
- Key Vault: kvvinceanalyticscontaine + dev
- Container App: ca-vince-app-dev
```

## Expected Deployment Flow

When `azd up` is run:

1. **azd provision** calls preprovision hook
   - Checks/creates resource group
   - Terraform init & validate

2. **azd provision** runs terraform apply
   - Uses main.tfvars.json for variable mapping
   - Creates all Azure resources per existing Terraform

3. **azd provision** calls postprovision hook  
   - Extracts deployment outputs
   - Shows Vince URL and credential info

4. **azd deploy** (no-op for this infrastructure-only template)

5. **azd** shows next-steps.json guidance

## Troubleshooting Common Issues

### Missing terraform binary
- Hook scripts handle this gracefully
- Users need Terraform installed for actual deployment

### Resource group permissions
- Preprovision hook creates RG if needed
- Requires Contributor rights on subscription/RG

### Variable substitution
- Check azd environment variables: `azd env get-values`
- Verify main.tfvars.json syntax with `jq . iac/main.tfvars.json`