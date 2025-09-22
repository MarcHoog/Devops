function Select-FromMenu($title, $options) {
    $keys = @($options.Keys)   # capture as array in fixed order
    Write-Host "`n$title" -ForegroundColor Cyan
    for ($i = 0; $i -lt $keys.Count; $i++) {
        Write-Host "[$($i + 1)] $($keys[$i])"
    }
    do {
        $choice = Read-Host "Choose 1-$($keys.Count)"
    } until ($choice -match '^\d+$' -and [int]$choice -gt 0 -and [int]$choice -le $keys.Count)

    $selectedKey = $keys[$choice - 1]
    return [PSCustomObject]@{
        Name  = $selectedKey
        Value = $options[$selectedKey]
    }
}
