# Azure Governance-as-Code: Shifting Security Left with Bicep & Azure Policy

This project demonstrates a real-world Governance-as-Code workflow. By integrating Azure Policy validation directly into an Azure DevOps CI/CD pipeline, we "shift-left" security—identifying and blocking non-compliant infrastructure before it is ever deployed.

## 🎯 Project Objective
To create a automated gatekeeper that:
1. Validates Bicep templates against organizational compliance rules.
2. Uses the `What-If` operation to perform pre-flight checks.
3. Blocks deployments that violate "Deny" policies (specifically Key Vault Purge Protection).

## 🏗️ Architecture & Tools
- **IaC:** Bicep
- **CI/CD:** Azure Pipelines (YAML)
- **Governance:** Azure Policy (Built-in "Deletion Protection" policy)
- **Security:** Workload Identity Federation (OIDC) for Service Connections
- **CLI:** Azure CLI (`az deployment group what-if`)

---

## 🛠️ Implementation Phases

### Phase 1: Policy Establishment
I assigned the built-in policy `Key vaults should have deletion protection enabled` to a specific Resource Group. I configured the effect to Deny, creating a hard boundary for non-compliant resources.

### Phase 2: Infrastructure Authoring
I authored a `keyvault.bicep` file. To test the governance guardrails, I intentionally set the `enablePurgeProtection` property to `false`.

### Phase 3: The Validation Pipeline
The pipeline uses a `Validate` stage to run the `What-If` command. This is critical because it triggers the Azure Resource Manager (ARM) evaluation engine without actually changing state.

### Phase 4: Remediation & Deployment

Once the pipeline successfully blocked the "illegal" Bicep code, I remediated the template by setting `enablePurgeProtection: true`. This allowed the pipeline to pass and proceed to the `Deploy` stage.

---

## 🔍 Lessons Learned & Troubleshooting

During implementation, I encountered and resolved several real-world issues:

- **Case Sensitivity in Bicep:** Resolved `Error BCP083` where I used `resourceGroup().Id` instead of the required lowercase `resourceGroup().id`.
- **CLI Syntax Changes:** Updated the `--result-format` parameter from the deprecated `ResourcePayloads` to the current `FullResourcePayloads` to accommodate Azure CLI agent updates.
- **Policy Latency:** Documented the 5-15 minute replication window required for new Azure Policy assignments to take effect across the control plane.

## 🚀 How to Run

1. Assign the "Key Vault Deletion Protection" policy to your target RG with the `Deny` effect.
2. Configure a Service Connection in Azure DevOps using Workload Identity Federation.
3. Push the `keyvault.bicep` and `azure-pipelines.yml` to your repo.
4. Observe the pipeline fail on the first run (intentional violation).
5. Fix the Bicep code and watch the CI/CD cycle complete successfully.