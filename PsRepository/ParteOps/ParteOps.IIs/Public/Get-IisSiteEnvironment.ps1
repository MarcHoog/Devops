function Get-IisSitePortalVar {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [string]$SiteName
    )

    # Prepare result
    $result = [ordered]@{
        SiteName = $SiteName
        Config = $null
        SID    = $null
    }

    [xml]$iisConfig = Get-Content "$env:windir\System32\inetsrv\config\applicationHost.config"

    $AppPoolName = Get-IisSitePool -Filter $SiteName | Select-Object -ExpandProperty ApplicationPool
    if (-not $AppPoolName) {
        Write-Warning "[$SiteName] No application pool found."
        return [PSCustomObject]$result
    }

    $loc = $iisConfig.configuration.location | Where-Object { $_.path -eq $SiteName }
    if ($loc) {
        $envVar = $null
        if ($null -ne $loc.'system.webServer'.aspNetCore) {
            $envVar = $loc.'system.webServer'.aspNetCore.environmentVariables.environmentVariable |
                    Where-Object { $_.name -eq "PORTAAL_CONFIG" } |
                    Select-Object -First 1

        if ($envVar) {
            Write-Host "[$SiteName] Found PORTAAL_CONFIG in applicationHost.config" -ForegroundColor Green  
            $result.Config = $envVar.value
            $result.SID = $null
            }
        }
    }

    if ($null -eq $result.Config) {
        try {
            Write-Host "[$SiteName] Resolving registry SID for application pool '$AppPoolName'" -ForegroundColor Yellow
            $ntAccount = New-Object System.Security.Principal.NTAccount("IIS AppPool\$AppPoolName")
            $sid       = $ntAccount.Translate([System.Security.Principal.SecurityIdentifier]).Value
            $result.SID = $sid

            $regPath = "Registry::HKEY_USERS\$sid\Environment"
            if (Test-Path $regPath) {
                $value = Get-ItemProperty -Path $regPath -Name "PORTAAL_CONFIG" -ErrorAction SilentlyContinue
                if ($value) {
                    $result.Config = $value.PORTAAL_CONFIG
                }
            }
        }
        catch {
            Write-Warning "[$SiteName] Could not resolve registry SID: $_"
        }
    }

    [PSCustomObject]$result
}
