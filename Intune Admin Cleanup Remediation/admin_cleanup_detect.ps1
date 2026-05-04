#Intune Detection Script
#exit 1 = error, will process remediation
#exit 0 = Nothing to remediate.

$ErrorActionPreference = "Stop"

#Make sure to have a comma after each entry, except for the last one
#Enter users display names in intune. No domain prefix or suffix.
$ApprovedAdmins = @(
    "BUILTIN\Administrator",
    "AzureAD\Cloud Device Administrators",
    "john.smith"
)

function Get-LocalAdmins {
    Get-LocalGroupMember -Group "Administrators" |
        Where-Object { $_.ObjectClass -in @("User", "Group") }
}

#Builds list of users not in Approved Admins list
$Unauthorized = @()

foreach ($Member in (Get-LocalAdmins)) {

    # Normalize name, remove domain prefix from Get-LocalAdmins output
    $Name = $Member.Name.Split('\')[-1]

    # Allow exact match
    if ($ApprovedAdmins -contains $Name) {
        continue
    }

    # Allow built-in Administrator by SID (RID 500)
    if ($Member.SID -match "-500$") {
        continue
    }

    $Unauthorized += $Name
}

if ($Unauthorized.Count -gt 0) {
    Write-Output "Unauthorized local admins detected: $($Unauthorized -join ', ')"
    exit 1
}
else {
Write-Output "No unauthorized local administrators found."
exit 0
}
