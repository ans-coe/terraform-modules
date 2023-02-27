Workflow ManagePower-AzWebApp {
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
    $Resources = Get-AzWebApp -DefaultProfile $AzureContext `
      -ResourceGroupName $ResourceGroupName `
      | Where-Object { $_.Tags[$Tag] -eq "$TagValue" }
  } Else {
    Write-Output "Collecting resources with the tag $Tag=$TagValue"
    $Resources = Get-AzWebApp -DefaultProfile $AzureContext  `
      | Where-Object { $_.Tags[$Tag] -eq "$TagValue" }
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
    ForEach -Parallel ($WA in $Resources) {
      Write-Output "Starting Web App $($WA.Name) in $($WA.ResourceGroup)."
      Start-AzWebApp -DefaultProfile $AzureContext `
        -Name $WA.Name -ResourceGroupName $WA.ResourceGroup
      Write-Output "Started Web App $($WA.Name) in $($WA.ResourceGroup)."
    }
  } ElseIf ($Action -eq "Stop") {
    ForEach -Parallel ($WA in $Resources) {
      Write-Output "Stopping Web App $($WA.Name) in $($WA.ResourceGroup)."
      Stop-AzWebApp -DefaultProfile $AzureContext `
        -Name $WA.Name -ResourceGroupName $WA.ResourceGroup
      Write-Output "Stopped Web App $($WA.Name) in $($WA.ResourceGroup)."
    }
  } Else {
    Write-Output "Action List used. No changes will be made to the state of the resources."
  }
}
