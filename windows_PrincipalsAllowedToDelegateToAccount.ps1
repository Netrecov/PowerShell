Import-Module ActiveDirectory

$ErrorActionPreference = "Stop"

# Variables

$fileServerName = "FILESERVER01"

$newServers = @(
    "SERVERA",
    "SERVERB",
    "SERVERC"
)

$newGMSAs = @(
    "MyGMSA1",
    "MyGMSA2",
    "MyGMSA3"
)

# Get the file server computer object and existing delegation principals

$fileServer = Get-ADComputer $fileServerName `
    -Properties PrincipalsAllowedToDelegateToAccount

$currentPrincipals = $fileServer.PrincipalsAllowedToDelegateToAccount

# Build new principals as AD objects

$newPrincipals = @()

foreach ($server in $newServers) {
    $computer = Get-ADComputer $server
    $newPrincipals += Get-ADObject -Identity $computer.DistinguishedName
}

foreach ($gmsa in $newGMSAs) {
    $gmsaObject = Get-ADServiceAccount $gmsa
    $newPrincipals += Get-ADObject -Identity $gmsaObject.DistinguishedName
}

# Combine existing and new principals

$updatedPrincipals = @(
    $currentPrincipals
    $newPrincipals
) | Sort-Object DistinguishedName -Unique

# Display intended configuration

Write-Host ("Principals that will be allowed to delegate to {0}:" -f $fileServerName)

$updatedPrincipals |
    Select-Object Name,ObjectClass,DistinguishedName |
    Format-Table -AutoSize

# Confirm before modifying AD

$confirm = Read-Host "Proceed with updating $fileServerName? (Y/N)"

if ($confirm -ne "Y") {
    Write-Host "Cancelled"
    exit
}

# Apply RBCD configuration

Set-ADComputer $fileServerName `
    -PrincipalsAllowedToDelegateToAccount $updatedPrincipals

# Verify

Write-Host "`nVerification:"

(Get-ADComputer $fileServerName `
    -Properties PrincipalsAllowedToDelegateToAccount).PrincipalsAllowedToDelegateToAccount |
    Select-Object Name,ObjectClass,DistinguishedName |
    Format-Table -AutoSize
