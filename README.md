# Azure Governance-as-Code: Shifting Security Left with Bicep & Azure Policy

This project demonstrates a real-world **Governance-as-Code** workflow. By integrating Azure Policy validation directly into an Azure DevOps CI/CD pipeline, we "shift-left" security—identifying and blocking non-compliant infrastructure before it is ever deployed.



## 🎯 Project Objective
To create a automated gatekeeper that:
1. Validates Bicep templates against organizational compliance rules.
2. Uses the `What-If` operation to perform pre-flight checks.
3. Blocks deployments that violate "Deny" policies (specifically Key Vault Purge Protection).

## 🏗️ Architecture & Tools
* **IaC:** Bicep
* **CI/CD:** Azure Pipelines (YAML)
* **Governance:** Azure Policy (Built-in "Deletion Protection" policy)
* **Security:** Workload Identity Federation (OIDC) for Service Connections
* **CLI:** Azure CLI (`az deployment group what-if`)

---

## 🛠️ Implementation Phases

### Phase 1: Policy Establishment
I assigned the built-in policy `Key vaults should have deletion protection enabled` to a specific Resource Group. I configured the effect to **Deny**, creating a hard boundary for non-compliant resources.

### Phase 2: Infrastructure Authoring
I authored a `keyvault.bicep` file. To test the governance guardrails, I intentionally set the `enablePurgeProtection` property to `false`.

### Phase 3: The Validation Pipeline
The pipeline uses a `Validate` stage to run the `What-If` command. This is critical because it triggers the Azure Resource Manager (ARM) evaluation engine without actually changing state.

```yaml
# Snippet of the validation task
- task: AzureCLI@2
  inputs:
    azureSubscription: $(serviceConnection)
    scriptType: 'bash'
    scriptLocation: 'inlineScript'
    inlineScript: |
      az deployment group what-if \
        --resource-group $(resourceGroupName) \
        --template-file ./keyvault.bicep \
        --result-format FullResourcePayloads