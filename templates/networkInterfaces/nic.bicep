@description('Location for all resources.')
param location string = resourceGroup().location
param publicIpName string = 'myPublicIP'

param nicName string = 'myVMNic'
param virtualNetworkName string = 'MyVNET'
param subnetName string = 'Subnet'

resource virtualNetwork 'Microsoft.Network/virtualNetworks@2022-05-01' existing = {
  name: virtualNetworkName
}

resource publicIp 'Microsoft.Network/publicIPAddresses@2022-05-01' existing = {
  name: publicIpName
}

resource nic 'Microsoft.Network/networkInterfaces@2022-05-01' = {
  name: nicName
  location: location
  properties: {
    ipConfigurations: [
      {
        name: 'ipconfig1'
        properties: {
          privateIPAllocationMethod: 'Dynamic'
          publicIPAddress: {
            id: publicIp.id
          }
          subnet: {
            id: resourceId('Microsoft.Network/virtualNetworks/subnets', virtualNetworkName, subnetName)
          }
        }
      }
    ]
  }
  dependsOn: [
    virtualNetwork
  ]
}
