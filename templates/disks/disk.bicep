@description('Location for all resources.')
param location string = resourceGroup().location

param name string
param sku string
param diskSizeGB int = 256
param diskIOPSReadWrite int = 500
param diskMBpsReadWrite int = 60

resource disk 'Microsoft.Compute/disks@2022-07-02' = {
  name: name
  location: location
  sku: {
    name: sku
  }
  properties: {
    creationData: {
      createOption: 'Empty'
    }
    diskSizeGB: diskSizeGB
    diskIOPSReadWrite: diskIOPSReadWrite
    diskMBpsReadWrite: diskMBpsReadWrite
    encryption: {
      type: 'EncryptionAtRestWithPlatformKey'
    }
    networkAccessPolicy: 'AllowAll'
    publicNetworkAccess: 'Enabled'
  }
}
