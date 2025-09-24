Write-Verbose "Loading ParteOps.IIs submodule"

# Import private first
$private = Get-ChildItem -Path $PSScriptRoot\Private\*.ps1 -ErrorAction SilentlyContinue
foreach ($file in $private) {
    . $file.FullName
}

# Then public
$public = Get-ChildItem -Path $PSScriptRoot\Public\*.ps1 -ErrorAction SilentlyContinue
foreach ($file in $public) {
    . $file.FullName
}

# Export only public functions
$functions = $public | ForEach-Object { [System.IO.Path]::GetFileNameWithoutExtension($_.Name) }
Export-ModuleMember -Function $functions
