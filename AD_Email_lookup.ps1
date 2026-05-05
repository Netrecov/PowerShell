Import-Module ActiveDirectory

$results = foreach ($row in Import-Csv "emails.csv") {

    $email = $row.Email.Trim().ToLower()

    # Try exact match on mail
    $user = Get-ADUser -Filter "mail -eq '$email'" -Properties mail, proxyAddresses, userPrincipalName

    # If not found, try proxyAddresses (aliases)
    if (-not $user) {
        $user = Get-ADUser -Filter "proxyAddresses -like '*$email*'" -Properties mail, proxyAddresses, userPrincipalName
    }

    if ($user) {
        [PSCustomObject]@{
            Email             = $email
            Found             = $true
            Name              = $user.Name
            SamAccountName    = $user.SamAccountName
            UserPrincipalName = $user.UserPrincipalName
            PrimaryEmail      = $user.mail
        }
    }
    else {
        [PSCustomObject]@{
            Email             = $email
            Found             = $false
            Name              = $null
            SamAccountName    = $null
            UserPrincipalName = $null
            PrimaryEmail      = $null
        }
    }
}

$results | Export-Csv "results.csv" -NoTypeInformation
