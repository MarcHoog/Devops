function Set-IisSites {
    [CmdletBinding()]
    param (
        [string] $JsonFilePath,
        [switch] $Clipboard,
        [array] $RenamePrefix,
        [switch] $RenamePoolToSite,
        [string] $Filter = "*"
    )

        if ($RenamePrefix -and $RenamePrefix.Count -ne 2) {
            throw "RenamePrefix must be an array of two strings: the old prefix and the new prefix."
        }       

        $appcmd = Join-Path $env:WINDIR "System32\inetsrv\appcmd.exe"
        if (-not (Test-Path $appcmd)) {
            throw "IIS does not appear to be installed on this machine."
        }

        if ($Clipboard) {
            $jsonContent = Get-Clipboard 
            if (-not $jsonContent) {
                throw "Clipboard is empty or does not contain valid JSON."
            }
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
        if ($RenamePrefix) {
            $oldPrefix = $RenamePrefix[0]
            $newPrefix = $RenamePrefix[1]
            foreach ($site in $sites) {
                if ($site.Name -like "$oldPrefix*") {
                    $site.Name = $site.Name -replace "^$oldPrefix", $newPrefix
                    Write-Host "Renamed site to: $($site.Name)"
                }
                if ($RenamePoolToSite) {
                    $site.ApplicationPool = $site.Name
                    Write-Host "Renamed application pool to match site name: $($site.ApplicationPool)"
                }
            }
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
                & $appcmd stop site /site.name:$siteName
                if ($site.PortalEnv) {
                    write-host "Setting PORTAAL_CONFIG environment variable for site '$siteName' to '$($site.PortalEnv)'            "
                    & $appcmd set config $siteName `
                        -section:system.webServer/aspNetCore `
                        /+"environmentVariables.[name='PORTAAL_CONFIG',value='$($site.PortalEnv)']" `
                        /commit:apphost
                }

                Write-Host "Created site: $siteName"
                Write-Host "Attached to application pool: $appPool"
            }

            Write-Host "----------------------------------------"
        }
}