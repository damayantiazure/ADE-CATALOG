@description('Application Insights name')
param appInsightName string
@description('Log Analytics workspace id')
param laWorkspaceId string
@description('Location of the resource')
param location string = resourceGroup().location

resource appInsights 'Microsoft.Insights/components@2020-02-02' = {
  name: appInsightName
  location: location
  kind: 'web'
  properties: {
    Application_Type: 'web'
    WorkspaceResourceId: laWorkspaceId 
  }
}


output InstrumentationKey string = appInsights.properties.InstrumentationKey
output ConnectionString string = appInsights.properties.ConnectionString 