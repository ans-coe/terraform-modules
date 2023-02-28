Workflow ManagePower-AzWebAppSlot {
  Param(
    [Parameter()]
    [ValidateNotNullOrEmpty()]
    [String]$Subscription = "${subscription_id}",

    [Parameter()]
    [String]$ResourceGroupName,

    [Parameter()]
    [String]$Tag = "power-management",

    [Parameter()]
    [String]$TagValue = "on",

    [Parameter()]
    [ValidateSet("Start", "Stop", "List")]
    [String]$Action = "List",

    [Parameter()]
    [String]$IdentityClientId = "System"
  )

  Try {
    # Ensures you do not inherit an AzContext in your runbook
    $Null = Disable-AzContextAutosave -Scope Process
  
    If ($IdentityClientId -eq "System") {
      $Null = Connect-AzAccount -Identity
    } Else {
      $Null = Connect-AzAccount -Identity -AccountId $IdentityClientId
    }

    $AzureContext = Set-AzContext -Subscription $Subscription
    Write-Output "Connected to $Subscription"
  } Catch {
    Write-Error "There is no system-assigned identity or the user assigned identity was not valid. Aborting.";
    Exit
  }

  If ($ResourceGroupName) {
    Write-Output "Collecting resources with the tag $Tag=$TagValue in the resource group $ResourceGroupName"
    $Resources = @()
    $WebApps = Get-AzWebApp -DefaultProfile $AzureContext -ResourceGroupName $ResourceGroupName
    ForEach ($App In $WebApps) {
      $Resources += (Get-AzWebAppSlot -DefaultProfile $AzureContext `
        -Name $App.Name -ResourceGroupName $App.ResourceGroup `
        | Where-Object { $_.Tags[$Tag] -eq "$TagValue" })
    }
  } Else {
    Write-Output "Collecting resources with the tag $Tag=$TagValue"
    $Resources = @()
    $WebApps = Get-AzWebApp -DefaultProfile $AzureContext
    ForEach ($App In $WebApps) {
      $Resources += (Get-AzWebAppSlot -DefaultProfile $AzureContext `
        -Name $App.Name -ResourceGroupName $App.ResourceGroup `
        | Where-Object { $_.Tags[$Tag] -eq "$TagValue" })
    }
  }

  # Based on the count of returned IDs instead of the count of returned objects
  If (($Resources.Id).Count -lt 1) {
    Write-Warning "No resources found with applicable filters. Exiting."
    Exit
  } Else {
    # Return JSON output as Powershell Workflow does not output objects as standard Powershell
    Write-Output "Performing $Action on the below resources:`n$($Resources.Id | ConvertTo-Json)"
  }

  If ($Action -eq "Start") {
    ForEach -Parallel ($WAS in $Resources) {
      Write-Output "Starting Web App Slot $($WAS.Name) in $($WAS.ResourceGroup)."
      Start-AzWebAppSlot -DefaultProfile $AzureContext `
        -Name ($WAS.Name -Split "/")[0] -Slot ($WAS.Name -Split "/")[1] -ResourceGroupName $WAS.ResourceGroup
      Write-Output "Started Web App Slot $($WAS.Name) in $($WAS.ResourceGroup)."
    }
  } ElseIf ($Action -eq "Stop") {
    ForEach -Parallel ($WAS in $Resources) {
      Write-Output "Stopping Web App Slot $($WAS.Name) in $($WAS.ResourceGroup)."
      Stop-AzWebAppSlot -DefaultProfile $AzureContext `
        -Name ($WAS.Name -Split "/")[0] -Slot ($WAS.Name -Split "/")[1] -ResourceGroupName $WAS.ResourceGroup
      Write-Output "Stopped Web App Slot $($WAS.Name) in $($WAS.ResourceGroup)."
    }
  } Else {
    Write-Output "Action List used. No changes will be made to the state of the resources."
  }
}
