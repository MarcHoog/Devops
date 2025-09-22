<#
.SYNOPSIS
    Export IIS site configuration details (name, app pool, path, bindings).

.DESCRIPTION
    This script reads the IIS applicationHost.config XML to extract information 
    about configured IIS sites. For each site it returns:
    - Name
    - Application Pool
    - Physical Path
    - Bindings (protocol + binding information)

    Optionally, the results can be filtered by site name and/or exported to 
    JSON and copied to the clipboard.

.PARAMETER Clipboard
    If specified, the site configuration will be converted to JSON and 
    copied to the clipboard.

.PARAMETER Filter
    A wildcard pattern used to filter sites by name. Defaults to "*" (all sites).

.EXAMPLE
    .\Get-IisSites.ps1
    Lists all IIS sites with their application pools, paths, and bindings.

.EXAMPLE
    .\Get-IisSites.ps1 -Filter "Website1"
    Shows only the configuration for the site "Website1".

.EXAMPLE
    .\Get-IisSites.ps1 -Clipboard
    Copies all site configuration (in JSON format) to the clipboard.
#>

[CmdletBinding()]
param (
    [switch] $Clipboard,
    [string] $Filter = "*"
)

    $appcmd = Join-Path $env:WINDIR "System32\inetsrv\appcmd.exe"
    if (-not (Test-Path $appcmd)) {
        throw "IIS does not appear to be installed on this machine."
    }

    [xml]$iisConfig = Get-Content "$env:windir\System32\inetsrv\config\applicationHost.config"


    $appPools = @{}
    foreach ($pool in $iisConfig.configuration.'system.applicationHost'.applicationPools.add) {
        $appPools[$pool.name] = [pscustomobject]@{
            Name       = $pool.name
            Runtime    = $pool.managedRuntimeVersion
            Pipeline   = $pool.managedPipelineMode
            AutoStart  = $pool.autoStart
        }
    }


    $sites = $iisConfig.configuration.'system.applicationHost'.sites.site | Foreach-Object {
        $siteName = $_.name
        $sitePath = $_.application.virtualDirectory.physicalPath
        $appPool    = $_.application.applicationPool
        $bindings  = @($_.bindings.binding | ForEach-Object {
        [pscustomobject]@{
            Protocol = $_.protocol
            BindingInformation = $_.bindingInformation
        }
    })

    [pscustomobject]@{
        Name = $siteName
        ApplicationPool = $appPool
        PoolSettings = if ($appPool -and $appPools.ContainsKey($appPool)) { $appPools[$appPool] } else { $null }
        PhysicalPath = $sitePath
        Bindings = $bindings
    }
}

if ($Filter -and $Filter -ne "*") {
    $sites = $sites | Where-Object { $_.Name -like $Filter }
}


$sites | Format-List
if ($Clipboard) {
    $sites | ConvertTo-Json -Depth 5 | clip
    Write-Host "Site configuration copied to clipboard."
}