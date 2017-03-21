$subscriptionId = "<<REMOVED>>"

# Connect to Azure
Login-AzureRmAccount
Select-AzureRmSubscription -SubscriptionId $subscriptionId

$resourceType = "Microsoft.DataLakeStore/accounts"

$dataLakeAccounts = Find-AzureRmResource -ResourceType $resourceType

foreach ($item in $dataLakeAccounts)
{
  # Write-Output $item.Name
  # Write-Output $item.ResourceGroupName

  $lockName = $item.Name + "-DL-Del-Lock"

  $getLock = Get-AzureRmResourceLock -Resourcename $item.Name -ResourceType $resourceType -Resourcegroup $item.ResourceGroupName

  $lockExists = New-Object -TypeName PSObject -Property @{lockType = $getLock.Properties.level} | Select-Object lockType       
  
  # $message = "==" + $lockExists + "=="
  # Write-Output $message

   if ($lockExists.lockType -ne "CanNotDelete")
   {
     # Add a lock
     $message = "Delete lock is being added on data lake: " + $item.Name
     Write-Output $message
     New-AzureRmResourceLock -LockLevel CanNotDelete -LockName $lockName -Resourcename $item.Name -ResourceType $resourceType -Resourcegroup $item.ResourceGroupName -Force
   }
   else
   {
     #Exists
     $message = "Delete lock already exists on data lake: " + $item.Name
     Write-Output $message
   }

} # foreach ($item in $dataLakeAccounts)

