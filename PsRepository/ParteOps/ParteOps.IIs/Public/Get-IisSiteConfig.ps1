function Get-IisSites {
    [CmdletBinding()]
    param (
        [switch] $Portal,
        [switch] $Clipboard,
        [string] $Filter = "*"
    )

    $appcmd = Join-Path $env:WINDIR "System32\inetsrv\appcmd.exe"
    if (-not (Test-Path $appcmd)) {
        throw "IIS does not appear to be installed on this machine."
    }

    [xml]$iisConfig = Get-Content "$env:windir\System32\inetsrv\config\applicationHost.config"

    # Collect application pool details
    $appPools = @{}
    foreach ($pool in $iisConfig.configuration.'system.applicationHost'.applicationPools.add) {
        $appPools[$pool.name] = [pscustomobject]@{
            Name      = $pool.name
            Runtime   = $pool.managedRuntimeVersion
            Pipeline  = $pool.managedPipelineMode
            AutoStart = $pool.autoStart
        }
    }

    # Collect site details
    $sites = $iisConfig.configuration.'system.applicationHost'.sites.site | ForEach-Object {
        $siteName = $_.name
        $sitePath = $_.application.virtualDirectory.physicalPath
         $appPool = & {
            if ($_.application.applicationPool) { $_.application.applicationPool }
            elseif ($_.applicationDefaults.applicationPool) { $_.applicationDefaults.applicationPool }
            else { $null }
        }
        $bindings = @($_.bindings.binding | ForEach-Object {
            [pscustomobject]@{
                Protocol            = $_.protocol
                BindingInformation  = $_.bindingInformation
            }
        })

        [pscustomobject]@{
            Name            = $siteName
            ApplicationPool = $appPool
            PoolSettings    = if ($appPool -and $appPools.ContainsKey($appPool)) { $appPools[$appPool] } else { $null }
            PhysicalPath    = $sitePath
            Bindings        = $bindings
            PortalEnv       = $null

        }
    }

    # Apply filter
    if ($Filter -and $Filter -ne "*") {
        $sites = $sites | Where-Object { $_.Name -like $Filter }
    }

    foreach ($site in $sites) {
        $site.PortalEnv = if ($Portal) { (Get-IisSitePortalVar -SiteName $site.Name).Config } else { $null }
    }

    if ($Clipboard) {
        $sites | ConvertTo-Json -Depth 5 | clip
        Write-Host "Site configuration copied to clipboard."
    }
    else {
        $sites
    }
}
