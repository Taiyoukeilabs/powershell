

Write-Host "This script will perform the following: `nTest for SysvolPath.`nCopy Necessary ADMX files.`nCreate the GPO.`nImport a backup GPO that contains all the settings.`n`n" -ForegroundColor Yellow
Read-Host -Prompt "Press Enter to proceed"

#Get current domain
$ADDomain = (Get-ADDomain).DNSRoot

#Use domain to establish SysVol path for portability
$SysVolPath = "\\$ADDomain\SYSVOL\$ADDomain\Policies\PolicyDefinitions"

#Very important to getting portability working
$ScriptDir = Split-Path -Parent $PSCommandPath
Set-Location $ScriptDir

#Testing if central Sysvol store exists, if not, kill the scirpt
if((Test-Path -Path $SysVolPath) -eq $false){

    Write-Host "SysVol Path does not exist" -ForegroundColor Red
    Read-Host -Prompt "Script Completed. Press Enter to exit"
    exit 1

}

Write-Host "`nCopying ADMX Files to: $SysVolPath .....`n"
#Firefox ADMX files
Copy-Item -Path "$ScriptDir\ADMX Files\Firefox\windows\*" -Destination $SysVolPath -Recurse -Force
Write-Host "Firefox ADMX files copied"

#Chrome ADMX files
Copy-Item -Path "$ScriptDir\ADMX Files\Chrome\admx\*" -Destination $SysVolPath -Recurse -Force
Write-Host "Google Chrome ADMX files copied"

#Edge ADMX Files
Copy-Item -Path "$ScriptDir\ADMX Files\Edge\windows\admx\*" -Destination $SysVolPath -Recurse -Force
Write-Host "MS Edge ADMX files copied"

#OneDrive ADMX files -- this one can cause issues if it's missing so adding it to avoid that
Copy-Item -Path "$ScriptDir\ADMX Files\OneDrive\*" -Destination $SysVolPath -Recurse -Force
Write-Host "OneDrive ADMX files copied"

Write-Host "`nAll ADMX files copied to: $SysVolPath `n" -ForegroundColor Green


################# GPO Creation and import #################


$GPOName = 'All Browser Force Updates'
$DomainDN = (Get-ADDomain).DistinguishedName

$ImportPath = "$ScriptDir\Backup"


Write-Host "Creating GPO and linking to top level...."

New-GPO -Name $GPOName | New-GPLink -Target $DomainDN -LinkEnabled Yes
Write-Host "GPO [$GPOName] has been created" -ForegroundColor Green

try {

    Import-GPO -BackupGpoName $GPOName -TargetName $GPOName -path $ImportPath
    
}
catch {

    $ErrorMessage = $_.Exception.Message
    Write-Host "`nFailed to import GPO settings: `n`n $ErrorMessage " -ForegroundColor Red
    Read-Host -Prompt "Script Completed. Press Enter to exit"
    exit 1

}

Write-Host "GPO Settings have been imported" -ForegroundColor Green

Write-Host "`nConfirming GPO creation and settings:`n`n"

Get-GPO -Name $GPOName

Write-Host "`n`n====================================`n`n" -ForegroundColor Green
Read-Host -Prompt "Script Completed. Press Enter to exit"
