
param gatewayName string 
param subnetId string
param backendFqdn string
param location string = resourceGroup().location
param instanceCount int = 2
param skuName string = 'Standard_v2'
param skuTier string = 'Standard_v2'

// some variables derived from the parameters
var gatewayIPConfigName = '${gatewayName}IpConfig'
var gatewayPublicIpAddressName = '${gatewayName}PublicIp'
var appGwPublicFrontendIpIPv4Name = '${gatewayName}PublicFrontendIpIPv4'
var appGwPortName = '${gatewayName}Port'
var listenerName = 'FrontEndListener'
var backendAddressPoolName = 'BackendPool'
var backendPoolSettingsName = 'BackendPoolSettings'
var requestRoutingRuleName = 'RoutingToStorageAccount'
var healthProbeName = 'DefaultHealthProbe'


module gatewayIpAddress 'public-ip.bicep' = {
  scope: resourceGroup()
  name: gatewayPublicIpAddressName
  params: {
    publicIpAddressName: gatewayPublicIpAddressName
    location: location
  }
}

resource appGateway 'Microsoft.Network/applicationGateways@2023-06-01' = {
  name: gatewayName
  location: location
  properties: {
    sku: {      
      name: skuName
      tier: skuTier
    }
    gatewayIPConfigurations: [
      {
        name: gatewayIPConfigName
        properties: {
          subnet: {
            id: subnetId
          }
        }
      }
    ]
    sslCertificates: []
    trustedRootCertificates: []
    trustedClientCertificates: []
    sslProfiles: []
    frontendIPConfigurations: [
      {
        name: appGwPublicFrontendIpIPv4Name
        properties: {
          privateIPAllocationMethod: 'Dynamic'
          publicIPAddress: {
            id: gatewayIpAddress.outputs.publicIPAddressId
          }
        }
      }
    ]
    frontendPorts: [
      {
        name: appGwPortName
        properties: {
          port: 80
        }
      }
    ]
    backendAddressPools: [
      {
        name: backendAddressPoolName
        properties: {
          backendAddresses: [
            {
              fqdn: backendFqdn
            }
          ]
        }
      }
    ]
    loadDistributionPolicies: []
    backendHttpSettingsCollection: [
      {
        name: backendPoolSettingsName
        properties: {
          port: 443
          protocol: 'Https'
          cookieBasedAffinity: 'Disabled'
          pickHostNameFromBackendAddress: true
          affinityCookieName: 'ApplicationGatewayAffinity'
          requestTimeout: 20
          probe: {            
            id: resourceId('Microsoft.Network/applicationGateways/probes', gatewayName, healthProbeName)
          }
        }
      }
    ]
    backendSettingsCollection: []
    httpListeners: [
      {
        name: listenerName        
        properties: {
          frontendIPConfiguration: {            
            id: resourceId('Microsoft.Network/applicationGateways/frontendIPConfigurations', gatewayName, appGwPublicFrontendIpIPv4Name)            
          }
          frontendPort: {
            id: resourceId('Microsoft.Network/applicationGateways/frontendPorts', gatewayName, appGwPortName)
          }
          protocol: 'Http'
          hostNames: []
          requireServerNameIndication: false
          customErrorConfigurations: []
        }
      }
    ]
    listeners: []
    urlPathMaps: []
    requestRoutingRules: [
      {
        name: requestRoutingRuleName        
        properties: {
          ruleType: 'Basic'
          priority: 1
          httpListener: {
            id: resourceId('Microsoft.Network/applicationGateways/httpListeners', gatewayName, listenerName)
          }
          backendAddressPool: {
            id: resourceId('Microsoft.Network/applicationGateways/backendAddressPools', gatewayName, backendAddressPoolName)
          }
          backendHttpSettings: {
            id: resourceId('Microsoft.Network/applicationGateways/backendHttpSettingsCollection', gatewayName, backendPoolSettingsName)
          }
        }
      }
    ]
    routingRules: []
    probes: [
      {
        name: healthProbeName
        properties: {
          protocol: 'Https'
          path: '/index.html'
          interval: 30
          timeout: 30
          unhealthyThreshold: 3
          pickHostNameFromBackendHttpSettings: true
          minServers: 0
          match: {
            statusCodes: [
              '404'
            ]
          }
        }
      }
    ]
    rewriteRuleSets: []
    redirectConfigurations: []
    privateLinkConfigurations: []
    enableHttp2: true
    autoscaleConfiguration: {
      minCapacity: 0
      maxCapacity: instanceCount
    }
  }
}
