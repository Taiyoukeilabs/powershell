#Specify the path to the CSV file
#Use Column named "displayName" and enter users display names in the cells below
#$csvPath = "C:\Temp\<fileName>.csv"

$csvPath = Import-Csv (Read-Host -Prompt "`nEnter filepath of CSV. Include name of CSV & file extension. Example: ""C:\Temp\<fileName>.csv""")

if ((Read-Host -Prompt "Are you sure you want to continue? This will offboard all users in CSV. (yes/no)") -eq 'no') {
                
    Write-Host -ForegroundColor Green "`n***** Exiting Script *****`n"
    exit
    
}

# Read the CSV file
$users = Import-Csv -Path $csvPath

# Loop through each user in the CSV
foreach ($user in $users) {
    $displayName = $user.displayName

    # Get the user based on display name
    $adUser = Get-ADUser -Filter { DisplayName -eq $displayName }

    # Check if the user exists
    if ($adUser) {

        Write-Host -ForegroundColor Yellow "`nBeginning Process for: $adUser"

        # Disable the user 
        Set-ADUser -Identity $adUser -Enabled $false
        Write-Host -ForegroundColor Cyan "User account has been disabled"

        #Hide them from GAL
        try{

            Set-adobject -Identity $adUser -replace @{msexchhidefromaddresslists = $true} 
            Write-Host -ForegroundColor Cyan "User has been hidden from GAL"

            }
        catch{

            Write-Host -ForegroundColor Red "Unable to hide from GAL. Check users Attributes and confirm msexchhidefromaddresslists exists."

            }

  

         # Remove the user from all groups
         $groups = Get-ADPrincipalGroupMembership $adUser | Select-Object name
         foreach ($group in $groups) {


            try{

             Remove-ADGroupMember -Identity $group.name -Members $adUser -Confirm:$false
             Write-Host -ForegroundColor Cyan "Removed from group: $($group.name)"

                }

            catch{ #cannot remove domain users group, so this will catch that and not leave a huge error message in the output
             
                Write-Host -ForegroundColor Red "Unable to remove group: $($group.name)"
             
                }

        }
      
      
    } else {

        Write-Host "User '$displayName' not found in Active Directory."

    }

    #Adds a timestamp to the description of the users object
    $currentDate = Get-Date
    Set-ADObject -Identity $adUser -Description "Disabled via script: $currentDate" 

    #Just doing this for clarity and orgnization of the output
    Write-Host -ForegroundColor Yellow "`nProcess completed for: $($adUser.Name)"
    Write-Host -ForegroundColor Red "`n====== NEXT USER ======`n"
}

Write-Host -ForegroundColor Green "************************`nScript Completed`nPlease refer to ITGlue Offboarding documentation for any further steps.`n************************"
