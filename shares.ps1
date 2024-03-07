$remoteServer = Read-Host "Enter the FQDN of the remote Windows server"
$credentials = Get-Credential
$defaultCsvPath = "C:\temp\$remoteServer-shares.csv"
$userCsvPath = Read-Host "Enter the full path for the CSV file where permissions will be saved [Default: $defaultCsvPath]"
$csvPath = if ([string]::IsNullOrWhiteSpace($userCsvPath)) { $defaultCsvPath } else { $userCsvPath }

$permissions = Invoke-Command -ComputerName $remoteServer -Credential $credentials -ScriptBlock {
    param($serverName)
    $allPermissions = @()
    $shares = Get-SmbShare
    foreach ($share in $shares) {
        $access = Get-SmbShareAccess -Name $share.Name |
        Select-Object @{Name='ComputerName';Expression={$serverName}}, Name, AccountName, AccessRight, @{Name='Path';Expression={$share.Path}}
        $allPermissions += $access
    }
    return $allPermissions
} -ArgumentList $remoteServer

$permissions | Export-Csv -Path $csvPath -NoTypeInformation

Write-Host "Permissions data saved to: $csvPath"
