@description('Location for all resources.')
param location string = resourceGroup().location

@description('Name of the virtual machine.')
param vmName string

resource vm 'Microsoft.Compute/virtualMachines@2022-11-01' existing = {
  name: vmName
}

resource virtualMachines_thetabcsync_name_AzureNetworkWatcherExtension 'Microsoft.Compute/virtualMachines/extensions@2022-11-01' = {
  parent: vm
  name: 'AzureNetworkWatcherExtension'
  location: location
  tags: {
    CreatedOnUTC: '2021-05-05T04:33:10.4438715Z'
  }
  properties: {
    autoUpgradeMinorVersion: true
    publisher: 'Microsoft.Azure.NetworkWatcher'
    type: 'NetworkWatcherAgentWindows'
    typeHandlerVersion: '1.4'
  }
}
