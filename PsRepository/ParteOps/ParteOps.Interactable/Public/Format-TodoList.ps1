function Format-TodoList {
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
            
            Write-Verbose "DEBUG INPUT: Raw choice = '$choice'" -ForegroundColor Red
            Write-Verbose "DEBUG INPUT: Choice length = $($choice.Length)" -ForegroundColor Red
            Write-Verbose "DEBUG INPUT: Choice as int = $($choice -as [int])" -ForegroundColor Red
            Write-Verbose "DEBUG INPUT: Choice type = $($choice.GetType().Name)" -ForegroundColor Red

            # More robust input parsing
            $choiceNum = $null
            $choiceTrimmed = $choice.Trim()
            if ([int]::TryParse($choiceTrimmed, [ref]$choiceNum)) {
                if ($choiceNum -ge 1 -and $choiceNum -le $todo.Count) {
                    $idx = $choiceNum - 1
                    $done[$idx] = -not $done[$idx]
                    Write-Verbose "DEBUG: After toggle - done[$idx] = $($done[$idx])" -ForegroundColor Magenta
                    Start-Sleep -Seconds 1
                } else {
                    Write-Verbose "DEBUG: Number out of range!" -ForegroundColor Red
                    Start-Sleep -Seconds 1
                }
            } else {
                Write-Verbose "DEBUG: Failed to parse as integer!" -ForegroundColor Red
                Start-Sleep -Seconds 1
            }
        }
    }
}
