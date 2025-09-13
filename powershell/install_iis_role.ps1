[CmdletBinding()]
param (
    [switch] $ManagementTools
)


$features = @('Web-Server')
$opts = @{ Name = $features}
if ($ManagementTools) {
    $opts['IncludeManagementTools'] = $true
}

$result = Install-WindowsFeature @opts

write-Host "IIS installation result: $($result.ResultCode)"
if ($result.ResultCode -ne 0) {
    throw "IIS installation failed with result code $($result.ResultCode)"
} else {
    write-Host "IIS installation succeeded."
}

if ($result.RestartNeeded) {
    Write-Host "A restart is required to complete the installation. Please restart the machine."
    Get-Input -Prompt "Do you want to restart now? (Y/N)" -ValidInputs @('Y', 'N') -Default 'Y' | ForEach-Object {
        if ($_ -eq 'Y') {
            Restart-Computer
        } else {
            Write-Host "Please remember to restart the machine later to complete the installation."
        }
    }

}
Write-Host "Done."