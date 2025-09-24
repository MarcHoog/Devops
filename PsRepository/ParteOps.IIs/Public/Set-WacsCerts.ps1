<#
.SYNOPSIS
Automates SSL certificate generation for IIS sites using win-acme (wacs.exe).

.DESCRIPTION
This script retrieves a list of IIS sites from `applicationHost.config`, filters
them by name (if specified), and invokes the win-acme client (`wacs.exe`) to
generate and install SSL certificates for each matching site.

The script:
- Validates the presence of `wacs.exe` at the given path.
- Loads IIS configuration directly from `applicationHost.config`.
- Optionally filters sites by name using a wildcard pattern.
- Prompts the user with a list of sites before execution.
- Calls `wacs.exe` for each site to issue and install certificates in IIS.

.PARAMETER Filter
A wildcard pattern used to filter IIS sites by name.
Default is `*` (all sites).

.PARAMETER WacsPath
The file path to `wacs.exe` (win-acme client).
Default is `C:\Program Files\win-acme\wacs.exe`.

.EXAMPLE
PS> .\Generate-Certs.ps1
Generates certificates for all IIS sites using the default `wacs.exe` path.

.EXAMPLE
PS> .\Generate-Certs.ps1 -Filter "MyApp*"
Generates certificates only for IIS sites with names starting with "MyApp".

.EXAMPLE
PS> .\Generate-Certs.ps1 -WacsPath "D:\tools\wacs.exe"
Uses a custom path to `wacs.exe` and processes all IIS sites.

#>

[CmdletBinding()]
param (
    [string] $Filter = "*",
    [string] $WacsPath = "C:\Program Files\win-acme\wacs.exe"
)

    if (-not (Test-Path $WacsPath)) {
        throw "The specified path to wacs.exe does not exist."
    }

    [xml]$iisConfig = Get-Content "$env:windir\System32\inetsrv\config\applicationHost.config" # The IIS Config file
    $sites = $iisConfig.configuration.'system.applicationHost'.sites.site | ForEach-Object {
        [pscustomobject]@{
            Name = $_.name
            SiteId = $_.id
        }
    }

    if ($Filter -and $Filter -ne "*") {
        $sites = $sites | Where-Object { $_.Name -like $Filter }
    }

    Read-Host -Prompt "Press Enter to continue with Generating Certificates: `n $($sites | Format-Table | Out-String)"

    foreach ($site in $sites) {
        Write-Host "Processing site: $($site.Name):$($site.SiteId)" -ForegroundColor Cyan
        & $WacsPath --target iis --siteid $site.SiteId --installation iis
    }