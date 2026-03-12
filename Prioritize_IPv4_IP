######### Remediation #########
$RegPath   = 'HKLM:\SYSTEM\CurrentControlSet\Services\Tcpip6\Parameters'
$ValueName = 'DisabledComponents'

# If you intend to use hex 0x20 instead, use: $Desired = 0x20   # (= 32 decimal)
#$Desired   = [uint32]32   # decimal 20
$Desired = [uint32]0x20


try {
    # Ensure the registry key exists
    if (-not (Test-Path -Path $RegPath)) {
        New-Item -Path $RegPath -Force | Out-Null
    }

    # Try to read existing value (will be $null if missing)
    $Current = $null
    try {
        $Current = (Get-ItemProperty -Path $RegPath -Name $ValueName -ErrorAction Stop).$ValueName
    } catch {
        # Value doesn't exist yet
        $Current = $null
    }

    if ($null -eq $Current) {
        # Create the DWORD value
        New-ItemProperty -Path $RegPath -Name $ValueName -PropertyType DWord -Value $Desired -Force | Out-Null
        Write-Host "Created $ValueName (DWORD) with value $Desired at $RegPath" -ForegroundColor Green
    }
    elseif ([int]$Current -ne [int]$Desired) {
        # Update the DWORD value
        Set-ItemProperty -Path $RegPath -Name $ValueName -Value $Desired -Force
        Write-Host "Updated $ValueName from $Current to $Desired at $RegPath" -ForegroundColor Yellow
    }
    else {
        Write-Host "$ValueName already set correctly to $Desired at $RegPath" -ForegroundColor Cyan
    }

    # Output final state for verification
    $Final = (Get-ItemProperty -Path $RegPath -Name $ValueName).$ValueName
    Write-Host "Final value: $ValueName = $Final" -ForegroundColor Magenta
}
catch {
    Write-Error "Failed to set registry value. Error: $($_.Exception.Message)"
    throw
}

######### Detection #########

$regkey = "HKLM:\SYSTEM\CurrentControlSet\Services\Tcpip6\Parameters"
$name = "DisabledComponents"
$value = 0x20

$existence = (Get-ItemPropertyvalue -path $regkey -Name $name)

if ($existence -ne $value) {
    Write-host "Not Found"
    exit 1
}
    else {
        Write-Host "Found"
        exit 0
    }
