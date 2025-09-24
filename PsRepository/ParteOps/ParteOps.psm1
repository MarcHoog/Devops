Write-Verbose "Loading ParteOps module and its submodules..."

# Import all submodules
Get-ChildItem -Path $PSScriptRoot\* -Directory | ForEach-Object {
    $subModule = Join-Path $_.FullName "$($_.Name).psm1"
    if (Test-Path $subModule) {
        Write-Verbose "Importing submodule: $($_.Name)"
        Import-Module $subModule -DisableNameChecking -Global -Force -Verbose
    }
}

Export-ModuleMember -Function * -Alias *
