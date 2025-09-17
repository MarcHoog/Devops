
[CmdletBinding()]
param (
    [string] $Filter = "*",
    [string] $WacsPath = "C:\Program Files\win-acme\wacs.exe"
)

    if (-not (Test-Path $WacsPath)) {
        throw "The specified path to wacs.exe does not exist."
    }

    [xml]$iisConfig = Get-Content "$env:windir\System32\inetsrv\config\applicationHost.config"
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
        Write-Host "----------------------------------------"
    }