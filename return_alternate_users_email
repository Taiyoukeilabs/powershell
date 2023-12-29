if((Read-Host -Prompt "Do you need to connect to AzureAD\MsolService Modules? (yes/no)") -eq 'yes')
{
    Connect-AzureAD | Out-Null
 
}

$user_list = Import-Csv (Read-Host -Prompt "`nEnter filepath of CSV (including file itself)")

$userOutput = @()

foreach ($user_object in $user_list){

    #Keeping this line here as a reference
    #$userOutput += Get-MsolDevice -RegisteredOwnerUpn $user.UserPrincipalName | select @{E = {$user.UserPrincipalName}; N = "UserPrincipalName"},DisplayName,DeviceOsType,DeviceTrustLevel,DeviceTrustType,Enabled,ApproximateLastLogonTimestamp

    $userOutput += Get-AzureADUser -ObjectId $user_object.userPrincipalName | select @{n='Alternate Email'; e={$_.OtherMails -join ' '}}, DisplayName,UserPrincipalName
}



$userOutput | Export-CSV c:\temp\ssg_community_personal_emails.csv -NoTypeInformation -Force
