Import-Module ActiveDirectory

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

# Display what will be configured
Write-Host "Principals that will be allowed to delegate to $fileServerName:"
$updatedPrincipals | Format-Table Name,ObjectClass,DistinguishedName

# Apply change
Set-ADComputer $fileServerName `
    -PrincipalsAllowedToDelegateToAccount $updatedPrincipals

# Verify
Write-Host "`nVerification:"
(Get-ADComputer $fileServerName `
    -Properties PrincipalsAllowedToDelegateToAccount).PrincipalsAllowedToDelegateToAccount |
    Format-Table Name,ObjectClass,DistinguishedName
