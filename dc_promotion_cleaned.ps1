<#
.SYNOPSIS
    Automates the promotion of a Windows Server to a Domain Controller using IFM.

.DESCRIPTION
    This script promotes a Windows Server to a Domain Controller using pre-staged
    IFM (Install From Media) and allows customization of various DSRM/DC settings.

.PARAMETER DomainName
    Fully Qualified Domain Name (FQDN) of the domain to join.

.PARAMETER ReplicationSourceDC
    The name of the source domain controller for replication.

.PARAMETER SiteName
    The name of the Active Directory site this DC will belong to.

.PARAMETER DatabasePath
    Local path for the NTDS database.

.PARAMETER SysvolPath
    Local path for the SYSVOL folder.

.PARAMETER LogPath
    Local path for log files.

.PARAMETER IFMPath
    Path to the IFM media (created with ntdsutil).

.EXAMPLE
    .\dc_promotion.ps1 -DomainName "domain.local" -ReplicationSourceDC "DC01" `
        -SiteName "Default-First-Site-Name" -IFMPath "D:\IFM"
#>

[CmdletBinding()]
param (
    [Parameter(Mandatory)]
    [string]$DomainName,

    [Parameter(Mandatory)]
    [string]$ReplicationSourceDC,

    [Parameter(Mandatory)]
    [string]$SiteName,

    [string]$DatabasePath = "C:\NTDS",
    [string]$SysvolPath = "C:\SYSVOL",
    [string]$LogPath = "C:\NTDS\Logs",
    [string]$IFMPath = "D:\IFM"
)

Install-ADDSDomainController `
    -NoGlobalCatalog:$false `
    -Credential (Get-Credential) `
    -CriticalReplicationOnly:$false `
    -DatabasePath $DatabasePath `
    -DomainName $DomainName `
    -InstallationMediaPath $IFMPath `
    -InstallDns:$false `
    -LogPath $LogPath `
    -NoRebootOnCompletion:$false `
    -ReplicationSourceDC $ReplicationSourceDC `
    -SiteName $SiteName `
    -SysvolPath $SysvolPath `
    -Force:$true
