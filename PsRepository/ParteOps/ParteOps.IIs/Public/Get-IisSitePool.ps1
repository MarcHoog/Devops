function Get-IisSitePool {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [string]$Filter
    )

    [xml]$iisConfig = Get-Content "$env:windir\System32\inetsrv\config\applicationHost.config"

    # Collect site details
    $sites = $iisConfig.configuration.'system.applicationHost'.sites.site | ForEach-Object {
        $siteName = $_.name
        $appPool = & {
            if ($_.application.applicationPool) { $_.application.applicationPool }
            elseif ($_.applicationDefaults.applicationPool) { $_.applicationDefaults.applicationPool }
            else { $null }
        }

        [pscustomobject]@{
            Name            = $siteName
            ApplicationPool = $appPool
        }
    }

    if ($Filter -and $Filter -ne "*") {
        $sites = $sites | Where-Object { $_.Name -like $Filter }
    }

    return $sites
}
