@description('Location for all resources.')
param location string = resourceGroup().location

@description('Name for the Public IP used to access the Virtual Machine.')
param publicIpName string = 'myPublicIP'

param publicIPAllocationMethod string = 'Dynamic'

param publicIpSku string = 'Basic'

@description('Name of the virtual machine.')
param vmName string = 'simple-vm'

@description('Unique DNS Name for the Public IP used to access the Virtual Machine.')
param dnsLabelPrefix string = toLower('${vmName}-${uniqueString(resourceGroup().id, vmName)}')

resource publicIp 'Microsoft.Network/publicIPAddresses@2022-05-01' = {
  name: publicIpName
  location: location
  sku: {
    name: publicIpSku
  }
  properties: {
    publicIPAllocationMethod: publicIPAllocationMethod
    dnsSettings: {
      domainNameLabel: dnsLabelPrefix
    }
  }
}
