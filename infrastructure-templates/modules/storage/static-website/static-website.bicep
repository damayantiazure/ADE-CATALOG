
param location string = resourceGroup().location
param IndexDocument string = 'index.html'
param ErrorDocument404Path string = 'error.html'
param storageAccountName string
@allowed([
  'Enabled'
  'Disabled'
])
param staticWebsiteState string = 'Enabled'

param userAssignedIdentityName string
param now string = utcNow('F')

resource setStorageStaticWebsite 'Microsoft.Resources/deploymentScripts@2020-10-01' = {
  name: substring(take(replace('setStaticWebsite-${storageAccountName}', '@', '_'), 64), 0, 1)
  identity: {
    type: 'UserAssigned'
    userAssignedIdentities: {
      '${resourceId('Microsoft.ManagedIdentity/userAssignedIdentities', userAssignedIdentityName)}': {}
    }
  }
  location: location
  kind: 'AzurePowerShell'
  properties: {
    azPowerShellVersion: '7.5.0'
    arguments: ' -IndexDocument ${IndexDocument} -ErrorDocument404Path ${ErrorDocument404Path} -storageAccountName ${storageAccountName} -StaticWebsiteState ${staticWebsiteState}'
    scriptContent: loadTextContent('enable-static-website.ps1')
    forceUpdateTag: now
    cleanupPreference: 'OnSuccess'
    retentionInterval: 'P1D'
    timeout: 'PT5M'
  }
}

output SkipSet bool = bool(int(setStorageStaticWebsite.properties.outputs.SkipSet))
output StaticWebsiteState string = setStorageStaticWebsite.properties.outputs.StaticWebsiteState
