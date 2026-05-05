# ---------------------------------------------------------
# AD Delta Sync with Progress Visuals
# ---------------------------------------------------------

Clear-Host
Write-Host "==========================================" -ForegroundColor Cyan
Write-Host "   AD CONNECT DELTA SYNC INITIATOR" -ForegroundColor Cyan
Write-Host "==========================================" -ForegroundColor Cyan
Write-Host ""

try {
    # 1. Check for the ADSync module
    Write-Host "Checking for ADSync module..." -NoNewline
    if (Get-Module -ListAvailable -Name ADSync) {
        Write-Host " [OK]" -ForegroundColor Green
    } else {
        throw "ADSync module not found. Please run this on your AD Connect server."
    }

    # 2. Start Progress Bar
    $ProgressParams = @{
        Activity = "Active Directory Delta Sync"
        Status = "Connecting to Azure AD Connect and triggering sync..."
        PercentComplete = 30
    }
    Write-Progress @ProgressParams

    # 3. Trigger the Delta Sync
    Start-ADSyncSyncCycle -PolicyType Delta

    # Update Progress
    $ProgressParams.Status = "Sync triggered successfully. Finalizing..."
    $ProgressParams.PercentComplete = 80
    Write-Progress @ProgressParams
    Start-Sleep -Seconds 2 # Brief pause for visual effect

    # 4. Final Success Output
    Write-Progress -Activity "Sync" -Completed
    
    Write-Host "------------------------------------------"
    Write-Host " STATUS: SUCCESS" -ForegroundColor Black -BackgroundColor Green
    Write-Host " INFO:   The Delta Sync has been started."
    Write-Host " TIME:   $(Get-Date)"
    Write-Host "------------------------------------------"

}
catch {
    # 5. Failure Output
    Write-Progress -Activity "Sync" -Completed
    Write-Host "------------------------------------------"
    Write-Host " STATUS: FAILED" -ForegroundColor White -BackgroundColor DarkRed
    Write-Host " ERROR:  $($_.Exception.Message)"
    Write-Host "------------------------------------------"
}

Read-Host -Prompt "Press Enter to exit..."


#=====================
#Create a shortcut on the desktop from the ps1 file
#Under Properties of the shortcut use the following:
#Target: C:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe -executionpolicy bypass -file C:\scripts\AdSync.ps1
#Start In: C:\Windows\System32\WindowsPowerShell\v1.0
#=====================
