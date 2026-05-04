#Intune Remediation Script

$ErrorActionPreference = "Stop"

#Make sure to have a comma after each entry, except for the last one
$ApprovedAdmins = @(
    "BUILTIN\Administrator",
    "AzureAD\Cloud Device Administrators",
    "john.smith"
)

function Get-LocalAdmins {
    Get-LocalGroupMember -Group "Administrators" |
        Where-Object { $_.ObjectClass -in @("User", "Group") }
}


foreach ($Member in (Get-LocalAdmins)) {

    $Name = $Member.Name.Split('\')[-1]

    # Skip approved names
    if ($ApprovedAdmins -contains $Name) {
        continue
    }

    # Skip builtâ€‘in Administrator (RID 500)
    if ($Member.SID -match "-500$") {
        continue
    }

    try {
        Remove-LocalGroupMember -Group "Administrators" -Member $Member.Name
        Write-Output "Removed unauthorized admin: $Name"
    }
    catch {
        Write-Warning "Failed to remove $Name : $_"
    }
}

exit 0
