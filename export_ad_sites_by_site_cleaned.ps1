<#
.SYNOPSIS
    Exports Active Directory Sites, Subnets, and Server assignments to a CSV file.

.DESCRIPTION
    Queries the current AD forest for all sites and their corresponding subnets and servers,
    then exports the data to a specified CSV file.

.PARAMETER OutputPath
    Path to save the CSV file (e.g., C:\Exports\sites.csv)

.EXAMPLE
    .\export_ad_sites_by_site.ps1 -OutputPath "C:\Exports\sites.csv"
#>

param (
    [Parameter(Mandatory = $true)]
    [string]$OutputPath
)

try {
    $sites = [System.DirectoryServices.ActiveDirectory.Forest]::GetCurrentForest().Sites
    $results = @()

    foreach ($site in $sites) {
        $results += [PSCustomObject]@{
            SiteName = $site.Name
            Subnets  = ($site.Subnets -join ";")
            Servers  = ($site.Servers -join ";")
        }
    }

    $results | Export-Csv -Path $OutputPath -NoTypeInformation
    Write-Host "✅ Export completed successfully to $OutputPath" -ForegroundColor Green
} catch {
    Write-Error "❌ Failed to export AD site information: $_"
}
