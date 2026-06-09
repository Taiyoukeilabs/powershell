#Get current domain
$ADDomain = (Get-ADDomain).DNSRoot

#Use domain to establish SysVol path for portability
$SysVolPath = "\\$ADDomain\SYSVOL\$ADDomain\Policies\PolicyDefinitions"

#Testing if central Sysvol store exists, if not, kill the scirpt
if((Test-Path -Path $SysVolPath) -eq $false){

    Write-Host "SysVol Path does not exist" -ForegroundColor Red
    exit 1

}

Write-Host "Copying ADMX Files to: $SysVolPath .....`n"
#Firefox ADMX files
Copy-Item -Path "$PSScriptRoot\ADMX Files\Firefox\windows\*" -Destination $SysVolPath -Recurse -Force
Write-Host "Firefox ADMX files copied"

#Chrome ADMX files
Copy-Item -Path "$PSScriptRoot\ADMX Files\Chrome\admx\*" -Destination $SysVolPath -Recurse -Force
Write-Host "Google Chrome ADMX files copied"

#Edge ADMX Files
Copy-Item -Path "$PSScriptRoot\ADMX Files\Edge\windows\admx\*" -Destination $SysVolPath -Recurse -Force
Write-Host "MS Edge ADMX files copied"

#OneDrive ADMX files -- this one can cause issues if it's missing so adding it to avoid that
Copy-Item -Path "$PSScriptRoot\ADMX Files\OneDrive\*" -Destination $SysVolPath -Recurse -Force
Write-Host "OneDrive ADMX files copied"

Write-Host "`nAll ADMX files copied to: $SysVolPath `n" -ForegroundColor Green


################# GPO Creation and import #################


$GPOName = 'All Browser Force Updates'
$DomainDN = (Get-ADDomain).DistinguishedName

#Should still look into using relative pathing with -- $targetFolder = "$PSScriptRoot\MyFolder"
$ImportPath = "$PSScriptRoot\Backups"

Write-Host "Creating GPO and linking to top level...."

New-GPO -Name $GPOName | New-GPLink -Target $DomainDN -LinkEnabled Yes
Write-Host "GPO [$GPOName] has been created" -ForegroundColor Green

Import-GPO -BackupGpoName $GPOName -TargetName $GPOName -path $ImportPath
Write-Host "GPO Settings have been imported" -ForegroundColor Green

Write-Host "`nConfirming GPO creation and settings:`n`n"

Get-GPO -Name $GPOName

Write-Host "`n`n====================================`n`n" -ForegroundColor Green
Read-Host -Prompt "Script Completed. Press Enter to exit"
