# Organimmo AVD Development Box

Progressive learning project for Azure Virtual Desktop (AVD) using Bicep.

## Overview

This project uses the `avd-complete` module to deploy an AVD environment incrementally. You'll uncomment sections step-by-step to learn each component.

## Prerequisites

- Azure subscription with appropriate permissions
- Azure CLI installed
- Resource group: `rg-avd-organimmo-dev-weu` (or modify in deployment command)
- Basic understanding of Bicep syntax

## Progressive Learning Path

### Step 1: Deploy Workspace Only (Current State)

**What you'll learn:**
- Basic Bicep module usage
- Naming conventions
- Tag management
- Azure deployment process

**Deploy:**
```bash
# Create resource group
az group create \
  --name rg-avd-organimmo-dev-weu \
  --location westeurope

# Deploy workspace only
az deployment group create \
  --resource-group rg-avd-organimmo-dev-weu \
  --template-file main.bicep \
  --parameters parameters.bicepparam
```

**Verify:**
```bash
# Check workspace
az desktopvirtualization workspace show \
  --resource-group rg-avd-organimmo-dev-weu \
  --name ws-avd-organimmo-dev-weu
```

**What got created:**
- AVD Workspace: `ws-avd-organimmo-dev-weu`

---

### Step 2: Add Host Pool

**What you'll learn:**
- Host pool types (Pooled vs Personal)
- Load balancer types
- Session limits
- Registration tokens

**Uncomment in module** (`modules/virtual-desktop/avd-complete/main.bicep`):
- Lines 79-97: `hostPool` resource
- Lines 137-140: `hostPoolIds` and `hostPoolNames` outputs

**Uncomment in project** (`main.bicep`):
- Lines 82-83: Host pool outputs

**Redeploy:**
```bash
az deployment group create \
  --resource-group rg-avd-organimmo-dev-weu \
  --template-file main.bicep \
  --parameters parameters.bicepparam
```

**Verify:**
```bash
# Check host pool
az desktopvirtualization hostpool show \
  --resource-group rg-avd-organimmo-dev-weu \
  --name pool-avd-organimmo-devbox-dev-weu
```

**What got created:**
- Host Pool: `pool-avd-organimmo-devbox-dev-weu`
- Registration token (valid for 2 hours)

---

### Step 3: Add Application Groups

**What you'll learn:**
- Desktop vs RemoteApp groups
- Linking groups to host pools
- Workspace associations
- Resource dependencies

**Uncomment in module** (`modules/virtual-desktop/avd-complete/main.bicep`):
- Lines 99-112: `applicationGroup` resource
- Line 123: `applicationGroupReferences` in workspace
- Lines 125-127: `dependsOn` in workspace
- Lines 143-146: Application group outputs

**Uncomment in project** (`main.bicep`):
- Lines 85-86: Application group outputs

**Redeploy:**
```bash
az deployment group create \
  --resource-group rg-avd-organimmo-dev-weu \
  --template-file main.bicep \
  --parameters parameters.bicepparam
```

**Verify:**
```bash
# Check application group
az desktopvirtualization applicationgroup show \
  --resource-group rg-avd-organimmo-dev-weu \
  --name dag-avd-organimmo-desktop-dev-weu
```

**What got created:**
- Application Group: `dag-avd-organimmo-desktop-dev-weu`
- Linked to host pool and workspace

---

### Step 4: Assign Users and Test

**Assign users to application group:**
```bash
# Get application group ID
APP_GROUP_ID=$(az desktopvirtualization applicationgroup show \
  --resource-group rg-avd-organimmo-dev-weu \
  --name dag-avd-organimmo-desktop-dev-weu \
  --query id -o tsv)

# Assign user (replace with your user)
az role assignment create \
  --assignee user@domain.com \
  --role "Desktop Virtualization User" \
  --scope $APP_GROUP_ID
```

**Connect:**
1. Install [Remote Desktop client](https://docs.microsoft.com/en-us/azure/virtual-desktop/user-documentation/connect-windows-7-10)
2. Subscribe to workspace: `ws-avd-organimmo-dev-weu`
3. Sign in with assigned user
4. Launch desktop

---

## Experimentation Ideas

Once comfortable with the basics:

1. **Multiple host pools:**
   - Add a second pool in `parameters.bicepparam`
   - Test different load balancer types

2. **RemoteApp groups:**
   - Change application group type to `RemoteApp`
   - Deploy and compare behavior

3. **Personal desktops:**
   - Change host pool type to `Personal`
   - See how assignment differs

4. **Advanced tagging:**
   - Add custom tags in `parameters.bicepparam`
   - Track resources by tags

---

## Troubleshooting

**Deployment fails with "resource already exists":**
- Delete existing resources or use different names

**Cannot connect to desktop:**
- Verify user role assignment
- Check host pool has session hosts (separate deployment needed)
- Ensure Azure AD authentication is configured

**Registration token expired:**
- Redeploy to generate new token
- Token is valid for 2 hours by default

---

## Next Steps

- [ ] Deploy session hosts (VMs) to the host pool
- [ ] Configure FSLogix for user profiles
- [ ] Add monitoring and diagnostics
- [ ] Implement network security groups
- [ ] Create production-ready configuration

---

## Resource Naming Convention

| Resource Type | Pattern | Example |
|--------------|---------|---------|
| Workspace | `ws-avd-{project}-{env}-{region}` | `ws-avd-organimmo-dev-weu` |
| Host Pool | `pool-avd-{project}-{name}-{env}-{region}` | `pool-avd-organimmo-devbox-dev-weu` |
| Desktop App Group | `dag-avd-{project}-{name}-{env}-{region}` | `dag-avd-organimmo-desktop-dev-weu` |
| RemoteApp Group | `rag-avd-{project}-{name}-{env}-{region}` | `rag-avd-organimmo-apps-dev-weu` |

---

## Clean Up

```bash
# Delete all resources
az group delete \
  --name rg-avd-organimmo-dev-weu \
  --yes --no-wait
```

---

## References

- [Azure Virtual Desktop Documentation](https://docs.microsoft.com/en-us/azure/virtual-desktop/)
- [Bicep Documentation](https://docs.microsoft.com/en-us/azure/azure-resource-manager/bicep/)
- [AVD Naming Conventions](https://docs.microsoft.com/en-us/azure/cloud-adoption-framework/ready/azure-best-practices/resource-naming)
