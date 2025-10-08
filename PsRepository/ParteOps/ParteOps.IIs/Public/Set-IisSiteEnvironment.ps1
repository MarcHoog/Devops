function Set-SitePortaalConfig {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [string]$SiteName,

        [Parameter(Mandatory)]
        [string]$Value
    )

    Import-Module WebAdministration -ErrorAction Stop

    $filter = "location[@path='$SiteName']/system.webServer/aspNetCore/environmentVariables"    
    # Look for existing PORTAAL_CONFIG                
    $existing = Get-WebConfigurationProperty -pspath 'MACHINE/WEBROOT/APPHOST' `
                  -filter $filter `
                  -name "." `
                  -ErrorAction SilentlyContinue |
                Where-Object { $_.Attributes["name"].Value -eq "PORTAAL_CONFIG" }           

    if ($existing) {
        Write-Output "[$SiteName] PORTAAL_CONFIG already set to '$($existing.Attributes["value"].Value)'. Nothing changed."
        return
    }

    # Add only if missing   
    Add-WebConfigurationProperty -pspath 'MACHINE/WEBROOT/APPHOST' `
        -filter $filter `
        -name "." `
        -value @{name='PORTAAL_CONFIG'; value=$Value}           


}
