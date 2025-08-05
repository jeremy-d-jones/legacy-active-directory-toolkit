<#
.SYNOPSIS
    Queries or sets a specific registry key across all Domain Controllers in the forest.

.DESCRIPTION
    Connects to each Domain Controller and either checks for the presence of a registry key/value,
    or sets it to a specified value. Supports both modes via a parameter.

.PARAMETER Mode
    Operation to perform: "query" or "set".

.PARAMETER RegistryPath
    Path to the registry key (e.g., HKLM:\Software\Dell\ChangeAuditor\Agent)

.PARAMETER Name
    Name of the registry value to query or set.

.PARAMETER Value
    (Optional) Value to assign when using -Mode "set".

.EXAMPLE
    .\manage_dc_registry.ps1 -Mode query -RegistryPath "HKLM:\Software\Dell\ChangeAuditor\Agent" -Name disablescmhook

    .\manage_dc_registry.ps1 -Mode set -RegistryPath "HKLM:\Software\Dell\ChangeAuditor\Agent" -Name disablescmhook -Value 1
#>

param (
    [Parameter(Mandatory = $true)]
    [ValidateSet("query", "set")]
    [string]$Mode,

    [Parameter(Mandatory = $true)]
    [string]$RegistryPath,

    [Parameter(Mandatory = $true)]
    [string]$Name,

    [Parameter()]
    [string]$Value
)

# Prompt for credentials
$creds = Get-Credential

# Get list of all DCs
$dc_list = [System.DirectoryServices.ActiveDirectory.Forest]::GetCurrentForest().Domains |
    ForEach-Object { $_.DomainControllers } |
    ForEach-Object { $_.Name } | Sort-Object -Unique

foreach ($server in $dc_list) {
    if (Test-Connection -ComputerName $server -Count 1 -Quiet) {
        Write-Host "`n🔍 $server is reachable" -ForegroundColor Cyan

        Invoke-Command -ComputerName $server -Credential $creds -ScriptBlock {
            param ($Mode, $RegistryPath, $Name, $Value)

            try {
                if ($Mode -eq "query") {
                    $item = Get-ItemProperty -Path $RegistryPath -Name $Name -ErrorAction Stop
                    Write-Host "[FOUND] $Name = $($item.$Name)" -ForegroundColor Green
                } elseif ($Mode -eq "set") {
                    New-Item -Path $RegistryPath -Force | Out-Null
                    New-ItemProperty -Path $RegistryPath -Name $Name -PropertyType DWord -Value $Value -Force
                    Write-Host "[SET] $Name = $Value written successfully" -ForegroundColor Yellow
                }
            } catch {
                Write-Warning "❌ $($env:COMPUTERNAME): $_"
            }
        } -ArgumentList $Mode, $RegistryPath, $Name, $Value
    } else {
        Write-Warning "$server is NOT reachable"
    }
}
