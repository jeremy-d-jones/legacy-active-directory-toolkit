<#
.SYNOPSIS
    Checks all Domain Controllers for the presence of a specific Windows Update (KB).

.DESCRIPTION
    Queries each Domain Controller in the current forest to verify if a specified hotfix (KB) is installed.

.PARAMETER KBID
    The KB ID to search for (e.g., KB3011780)

.EXAMPLE
    .\check_dc_for_KB.ps1 -KBID KB3011780
#>

param (
    [Parameter(Mandatory = $true)]
    [string]$KBID
)

# Prompt for credentials
$Creds = Get-Credential

# Build list of DCs in the current forest
$DC_list = [System.DirectoryServices.ActiveDirectory.Forest]::GetCurrentForest().Domains |
    ForEach-Object { $_.DomainControllers } |
    ForEach-Object { $_.Name } | Sort-Object -Unique

Write-Host "`nChecking for $KBID on all Domain Controllers..." -ForegroundColor Cyan

foreach ($Server in $DC_list) {
    try {
        $hotfix = Get-HotFix -Id $KBID -ComputerName $Server -Credential $Creds -ErrorAction Stop
        Write-Host "[PASS] $KBID is installed on $Server" -ForegroundColor Green
    } catch {
        Write-Warning "[FAIL] $KBID is NOT found or could not be queried on $Server"
    }
}
