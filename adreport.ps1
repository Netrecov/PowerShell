Import-Module ActiveDirectory

Get-ADUser -Filter 'Enabled -eq $true' -Properties GivenName, Surname, Description, Title, TelephoneNumber, Fax, ipPhone |
    Select-Object `
        GivenName,
        Surname,
        Description,
        Title,
        TelephoneNumber,
        Fax,
        ipPhone |
    Tee-Object -Variable Users |
    Export-Csv -Path "C:\Temp\AD_Enabled_Users.csv" -NoTypeInformation -Encoding UTF8

$Users | Format-Table -AutoSize
