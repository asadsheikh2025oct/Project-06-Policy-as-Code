//keyvault.bicep

@description('The location where the key vault will be deployed')
param location string = resourceGroup().location

@description('A unique name for the keyvault')
param kvName string = 'kv-lab-${uniqueString(resourceGroup().id)}'

// bicep code that actually creates kv
resource vault 'Microsoft.KeyVault/vaults@2023-07-01' = {
  name: kvName
  location: location
  properties: {
    sku: {
      family: 'A'
      name: 'standard'      
    }
    tenantId: subscription().tenantId
    accessPolicies: [] // will set via RBAC if needed, leave empty for now
    enablePurgeProtection: false
  }
}

output vaultname string = vault.name
