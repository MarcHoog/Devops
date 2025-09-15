<#
.SYNOPSIS
    Import IIS sites and application pools from JSON.

.DESCRIPTION
    This script reads IIS site configuration from either a JSON file 
    or the clipboard, and recreates the sites and application pools 
    in IIS using appcmd.exe.
    
    - If the application pool already exists, it is skipped.
    - If the site already exists, it is skipped.
    - New application pools and sites are created with the same 
      name, physical path, and bindings as defined in the JSON.

.PARAMETER JsonFilePath
    The path to a JSON file containing exported site configuration.

.PARAMETER Clipboard
    If specified, the script reads JSON content from the clipboard instead.

.PARAMETER Filter
    A wildcard pattern used to filter sites by name before import. 
    Defaults to "*" (all sites).

.EXAMPLE
    .\Import-IisSites.ps1 -JsonFilePath "C:\temp\sites.json"
    Imports sites from a JSON file.

.EXAMPLE
    .\Import-IisSites.ps1 -Clipboard
    Imports sites directly from JSON content on the clipboard.

.EXAMPLE
    .\Import-IisSites.ps1 -JsonFilePath "C:\temp\sites.json" -Filter "Website1"
    Imports only the site named "Website1" from the JSON file.

#>

[CmdletBinding()]
param (
    [string] $JsonFilePath,
    [switch] $Clipboard,
    [string] $Filter = "*"
)

    $appcmd = Join-Path $env:WINDIR "System32\inetsrv\appcmd.exe"
    if (-not (Test-Path $appcmd)) {
        throw "IIS does not appear to be installed on this machine."
    }

    if ($Clipboard) {
        $jsonContent = Get-Clipboard
    } elseif ($JsonFilePath) {
        if (-not (Test-Path $JsonFilePath)) {
            throw "The specified JSON file path does not exist."
        }
        $jsonContent = Get-Content -Path $JsonFilePath -Raw
    } else {
        throw "You must specify either -JsonFilePath or -Clipboard."
    }

    $sites = $jsonContent | ConvertFrom-Json
    if ($Filter -and $Filter -ne "*") {
        $sites = $sites | Where-Object { $_.Name -like $Filter }
    }

    Read-Host -Prompt "Press Enter to continue with importing the following sites: `n $($sites | Format-Table | Out-String)" 

    foreach ($site in $sites) {
        $siteName = $site.Name
        $appPool = $site.ApplicationPool
        $physicalPath = $site.PhysicalPath
        $bindings = $site.Bindings
        $poolSettings = $site.PoolSettings


        & $appcmd list apppool /name:$appPool | Out-Null
        if ($LASTEXITCODE -eq 0) {
            Write-Host "Application pool '$appPool' already exists. Skipping creation."
        } else {
            & $appcmd add apppool /name:$appPool | Out-Null
            Write-Host "Created application pool: $appPool"
            if ($poolSettings) {
                Write-Host "Applying Configuration pool Settings: $appPool"
                if ($null -ne $poolSettings.Runtime) {
                    Write-Host "Setting Runtime to $($poolSettings.Runtime)"
                    & $appcmd set apppool /apppool.name:$appPool /managedRuntimeVersion:$($poolSettings.Runtime) | Out-Null
                }
                if ($null -ne $poolSettings.Pipeline) {
                    Write-Host "Setting Pipeline to $($poolSettings.Pipeline)"
                    & $appcmd set apppool /apppool.name:$appPool /managedPipelineMode:$($poolSettings.Pipeline) | Out-Null
                }
                if ($null -ne $poolSettings.AutoStart) {
                    Write-Host "Setting AutoStart to $($poolSettings.AutoStart)"
                    & $appcmd set apppool /apppool.name:$appPool /autoStart:$($poolSettings.AutoStart) | Out-Null
                }
            }
        }

        & $appcmd list site /name:$siteName | Out-Null
        if ($LASTEXITCODE -eq 0) { 
            Write-Host "Site '$siteName' already exists. Skipping creation." 
        } else {
            $bindingInfo = ($bindings | ForEach-Object { "$($_.Protocol)/$($_.BindingInformation)" }) -join ","
            & $appcmd add site /name:$siteName /bindings:$bindingInfo /physicalPath:$physicalPath | Out-Null
            & $appcmd set app /app.name:"$siteName/" /applicationPool:$appPool | Out-Null
            Write-Host "Created site: $siteName"
            Write-Host "Attached to application pool: $appPool"
        }

        Write-Host "----------------------------------------"
    }

