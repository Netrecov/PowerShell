Import-Module ActiveDirectory

$ErrorActionPreference = "Stop"

# Variables
$fileServerName = "FILESERVER01"

$newServers = @(
    "SERVERA",
    "SERVERB",
    "SERVERC"
)

$newGMSA = "MyGMSA"

# Get current delegation principals
$fileServer = Get-ADComputer $fileServerName `
    -Properties PrincipalsAllowedToDelegateToAccount

$currentPrincipals = $fileServer.PrincipalsAllowedToDelegateToAccount

# Get new computer objects
$newPrincipals = foreach ($server in $newServers) {
    Get-ADComputer $server
}

# Get gMSA object
$newPrincipals += Get-ADServiceAccount $newGMSA

# Combine existing + new entries
$updatedPrincipals = @(
    $currentPrincipals
    $newPrincipals
) | Sort-Object DistinguishedName -Unique

# Display planned change
Write-Host "Principals that will be allowed to delegate to $fileServerName:"
$updatedPrincipals | Format-Table Name,ObjectClass,DistinguishedName

$confirm = Read-Host "Proceed with update? (Y/N)"

if ($confirm -ne "Y") {
    Write-Host "Cancelled"
    exit
}

# Apply change
Set-ADComputer $fileServerName `
    -PrincipalsAllowedToDelegateToAccount $updatedPrincipals

# Verify
Write-Host "`nVerification:"
(Get-ADComputer $fileServerName `
    -Properties PrincipalsAllowedToDelegateToAccount).PrincipalsAllowedToDelegateToAccount |
    Format-Table Name,ObjectClass,DistinguishedName
