@description('Username for the Virtual Machine.')
param adminUsername string

@description('Password for the Virtual Machine.')
@minLength(12)
@secure()
param adminPassword string

@description('Size of the virtual machine.')
param vmSize string = 'Standard_A8m_v2'

@description('Location for all resources.')
param location string = resourceGroup().location

@description('Name of the virtual machine.')
param vmName string

param nicName string = 'myVMNic'
param storageAccountName string
param diskOsName string
param disk0Name string 
param disk1Name string

param diskOsSku string
param diskOsSizeGB int
param disk0Sku string
param disk0SizeGB int
param disk1Sku string
param disk1SizeGB int

/*param diskOsIOPSReadWrite int
param diskOsMBpsReadWrite int

param disk0Sku string
param disk0SizeGB int
param disk0IOPSReadWrite int
param disk0MBpsReadWrite int

param disk1Sku string
param disk1SizeGB int
param disk1IOPSReadWrite int 
param disk1MBpsReadWrite int*/

resource nic 'Microsoft.Network/networkInterfaces@2022-05-01' existing = {
  name: nicName
}

resource storageAccount 'Microsoft.Storage/storageAccounts@2022-05-01' existing = {
  name: storageAccountName
}

resource diskOs 'Microsoft.Compute/disks@2022-07-02' existing = {
  name: diskOsName
}

resource disk0 'Microsoft.Compute/disks@2022-07-02' existing = {
  name: disk0Name
}

resource disk1 'Microsoft.Compute/disks@2022-07-02' existing = {
  name: disk1Name
}

resource vm 'Microsoft.Compute/virtualMachines@2022-11-01' = {
  name: vmName
  location: location
  tags: {
    Practice: 'D365'
    Description: 'Business Central on prem to SaaS sync'
    Owner: 'Joerg Rau'
    CreatedOnUTC: 'Unknown'
  }
  properties: {
    hardwareProfile: {
      vmSize: vmSize
    }
    storageProfile: {
      imageReference: {
        publisher: 'microsoftsqlserver'
        offer: 'sql2019-ws2019'
        sku: 'standard'
        version: 'latest'
      }
      osDisk: {
        name: diskOsName
        osType: 'Windows'
        diskSizeGB: diskOsSizeGB
        createOption: 'FromImage'
        caching: 'ReadWrite'
        writeAcceleratorEnabled: false
        managedDisk: {
          storageAccountType: diskOsSku
        }
      }
      dataDisks: [
        {
          lun: 0
          name: disk0Name
          diskSizeGB: disk0SizeGB
          createOption: 'Attach'
          caching: 'None'
          writeAcceleratorEnabled: false
          managedDisk: {
            storageAccountType: disk0Sku
            id: disk0.id
          }
          toBeDetached: false
        }
        {
          lun: 1
          name: disk1Name
          diskSizeGB: disk1SizeGB
          createOption: 'Attach'
          caching: 'None'
          writeAcceleratorEnabled: false
          managedDisk: {
            storageAccountType: disk1Sku
            id: disk1.id
          }
          toBeDetached: false
        }
      ]
    }
    osProfile: {
      computerName: vmName
      adminUsername: adminUsername
      adminPassword: adminPassword
      windowsConfiguration: {
        provisionVMAgent: true
        enableAutomaticUpdates: true
        patchSettings: {
          patchMode: 'AutomaticByOS'
          assessmentMode: 'ImageDefault'
        }
      }
      secrets: []
      allowExtensionOperations: true
      requireGuestProvisionSignal: true
    }
    networkProfile: {
      networkInterfaces: [
        {
          id: nic.id
        }
      ]
    }
    diagnosticsProfile: {
      bootDiagnostics: {
        enabled: true
        storageUri: storageAccount.properties.primaryEndpoints.blob
      }
    }
  }
}
