Import-Module ActiveDirectory

Get-ADUser -Filter * -Properties GivenName, Surname, Description, Title, TelephoneNumber, Fax, ipPhone |
    Select-Object `
        GivenName,
        Surname,
        Description,
        Title,
        TelephoneNumber,
        Fax,
        ipPhone |
    Export-Csv -Path "C:\Temp\AD_Users.csv" -NoTypeInformation -Encoding UTF8
