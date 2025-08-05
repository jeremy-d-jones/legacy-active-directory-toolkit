<#
.SYNOPSIS
    Runs port validation checks against servers for services like log forwarding,
    Courion, SAMPs, and Change Auditor using portqry.exe.

.DESCRIPTION
    Uses portqry.exe to test if required services are listening on expected ports.
    Useful during Domain Controller promotion prep or validation phases.

.PARAMETER ServerGroups
    A hashtable defining server roles and ports. Example:
    @{
        "logforwarding" = @{ servers = @("log1", "log2"); port = 5985 }
        "courion"       = @{ servers = @("courion1"); port = 26000 }
        "samps"         = @{ servers = @("samps1"); port = 139 }
    }

.PARAMETER PortQryPath
    Full path to portqry.exe

.EXAMPLE
    .\dc_pre_validation.ps1 -PortQryPath "C:\Tools\portqry.exe"
#>

param (
    [Parameter(Mandatory = $true)]
    [string]$PortQryPath,

    [Parameter()]
    [hashtable]$ServerGroups = @{
        "logforwarding" = @{ servers = @("servername1", "servername2"); port = 5985 };
        "courion"       = @{ servers = @("servername3"); port = 26000 };
        "samps"         = @{ servers = @("servername4"); port = 139 };
        "changeauditor" = @{ servers = @("servername5"); port = 8000 }
    }
)

function Test-Port {
    param (
        [string]$Server,
        [int]$Port
    )
    $result = & $PortQryPath -n $Server -e $Port | Out-String
    if ($result -match "LISTENING") {
        Write-Host "[PASS] $Server is listening on port $Port" -ForegroundColor Green
    } else {
        Write-Warning "[FAIL] $Server is NOT listening on port $Port"
    }
}

foreach ($role in $ServerGroups.Keys) {
    $group = $ServerGroups[$role]
    $servers = $group["servers"]
    $port = $group["port"]

    Write-Host "`nValidating $role servers on port $port..." -ForegroundColor Cyan
    foreach ($srv in $servers) {
        Test-Port -Server $srv -Port $port
    }
}
