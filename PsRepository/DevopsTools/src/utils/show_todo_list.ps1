function Show-TodoList {
    [CmdletBinding()]
    param(
        [Parameter(ValueFromPipeline = $true)]
        [string[]]$Items
    )

    begin {
        $todo = @()
    }

    process {
        $todo += $Items
    }

    end {
        if (-not $todo) {
            Write-Host "No TODO items provided." -ForegroundColor Yellow
            return
        }

        # Track completion state
        $done = @{}
        for ($i = 0; $i -lt $todo.Count; $i++) {
            $done[[int]$i] = $false
        }

        # Work out number width for alignment (so 1–9, 10+, 100+ all align)
        $width = ($todo.Count).ToString().Length

        while ($true) {
            Clear-Host
            Write-Host "==== TODO List ====" -ForegroundColor Cyan

            for ($i = 0; $i -lt $todo.Count; $i++) {
                $num = ($i+1).ToString().PadLeft($width)  # properly padded number
                if ($done[[int]$i]) {
                    Write-Host ("$num. [x] $($todo[$i])") -ForegroundColor Green
                }
                else {
                    Write-Host ("$num. [ ] $($todo[$i])")
                }
            }

            Write-Host "`nType number to toggle, q to quit, d for debug" -ForegroundColor DarkGray
            $choice = Read-Host "Select"

            if ($choice -eq 'q') { break }
            
            if ($choice -eq 'd') {
                Write-Host "`nDEBUG INFO:" -ForegroundColor Yellow
                Write-Host "Todo count: $($todo.Count)" -ForegroundColor Yellow
                Write-Host "Done hashtable keys: $($done.Keys -join ', ')" -ForegroundColor Yellow
                Write-Host "Done hashtable values: $($done.Values -join ', ')" -ForegroundColor Yellow
                for ($i = 0; $i -lt $todo.Count; $i++) {
                    Write-Host "Index $i : Key exists = $($done.ContainsKey($i)), Value = $($done[$i])" -ForegroundColor Yellow
                }
                Read-Host "Press Enter to continue"
                continue
            }

            # Debug the input parsing
            Write-Host "DEBUG INPUT: Raw choice = '$choice'" -ForegroundColor Red
            Write-Host "DEBUG INPUT: Choice length = $($choice.Length)" -ForegroundColor Red
            Write-Host "DEBUG INPUT: Choice as int = $($choice -as [int])" -ForegroundColor Red
            Write-Host "DEBUG INPUT: Choice type = $($choice.GetType().Name)" -ForegroundColor Red
            Write-Host "DEBUG INPUT: ASCII values = $([System.Text.Encoding]::ASCII.GetBytes($choice) -join ',')" -ForegroundColor Red

            # More robust input parsing
            $choiceNum = $null
            $choiceTrimmed = $choice.Trim()
            if ([int]::TryParse($choiceTrimmed, [ref]$choiceNum)) {
                if ($choiceNum -ge 1 -and $choiceNum -le $todo.Count) {
                    $idx = $choiceNum - 1
                    Write-Host "DEBUG: Toggling index $idx (choice was $choice)" -ForegroundColor Magenta
                    Write-Host "DEBUG: Before toggle - done[$idx] = $($done[$idx])" -ForegroundColor Magenta
                    $done[$idx] = -not $done[$idx]
                    Write-Host "DEBUG: After toggle - done[$idx] = $($done[$idx])" -ForegroundColor Magenta
                    Start-Sleep -Seconds 1
                } else {
                    Write-Host "DEBUG: Number out of range!" -ForegroundColor Red
                    Start-Sleep -Seconds 1
                }
            } else {
                Write-Host "DEBUG: Failed to parse as integer!" -ForegroundColor Red
                Start-Sleep -Seconds 1
            }
        }
    }
}
