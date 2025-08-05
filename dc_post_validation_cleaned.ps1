<#
.SYNOPSIS
    Performs post-promotion health checks on a newly promoted Domain Controller.

.DESCRIPTION
    This script verifies SYSVOL presence, service status, SMB shares, and domain controller visibility.

.PARAMETER TranscriptPath
    Path to save transcript output.

.PARAMETER SysvolDrive
    Drive letter where SYSVOL is expected (e.g., G:)

.EXAMPLE
    .\dc_post_validation.ps1 -TranscriptPath "D:\Logs\post_check.txt" -SysvolDrive "G:"
#>

param (
    [string]$TranscriptPath = "C:\Temp\dc_post_validation_transcript.txt",
    [string]$SysvolDrive = "G:"
)

Start-Transcript -Path $TranscriptPath -Append

# Ensure AD module is available
Import-Module ActiveDirectory -ErrorAction Stop

# Set variables
$hostname = $env:COMPUTERNAME
$date = Get-Date
$sysvolPath = "$SysvolDrive\SYSVOL"
$sysvolExists = Test-Path $sysvolPath

# Display current date
Write-Host "`n📅 Current Date: $date"

# List all Domain Controllers
Write-Host "`n📍 List of Domain Controllers:"
Get-ADDomainController -Filter * | Format-Table Name, Site, IPv4Address -AutoSize

# Check SYSVOL folder
Write-Host "`n📂 Checking SYSVOL folder on $SysvolDrive:"
if ($sysvolExists) {
    Write-Host "✅ SYSVOL exists at $sysvolPath" -ForegroundColor Green
} else {
    Write-Warning "❌ SYSVOL NOT found at $sysvolPath"
}

# Check essential services
Write-Host "`n🔍 Checking required services:"
$requiredServices = "NTDS", "ADWS", "DFS", "DFSR", "DNSCACHE", "ISMSERV", "KDC", "NETLOGON", "REMOTEREGISTRY", "RPCEPTMAPPER", "LANMANSERVER", "W32TIME", "LANMANWORKSTATION"
Get-Service -Name $requiredServices | Format-Table DisplayName, Status, StartType

# Check SYSVOL and NETLOGON shares
Write-Host "`n📡 Checking for SYSVOL and NETLOGON shares:"
try {
    Get-SmbShare | Where-Object { $_.Name -in @("SYSVOL", "NETLOGON") } | Format-Table Name, Path, Description
} catch {
    Write-Warning "Unable to retrieve SMB shares. Ensure the SMB server feature is installed."
}

# Future: Certificate presence validation
# TODO: Add certificate check logic if required

Stop-Transcript
