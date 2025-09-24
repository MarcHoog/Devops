function Get-Group {
    param(
        [string] $GroupName,
        [switch] $IncludeGroupMembership,
        [switch] $Cache = $false
    )
    $scopes = @("Group.Read.All", "Group.ReadWrite.All", "Directory.Read.All", "User.Read.All")

    Connect-MgGraph -Scopes $scopes -NoWelcome
    $groups = Get-MgGroup -All | Where-Object { $_.GroupTypes -notcontains "Unified" } 

    $group = $groups | Where-Object { $_.DisplayName -eq $GroupName }
    if (-not $group) {
        Write-Host "Group could not be found: $GroupName" -ForegroundColor Red                          
    }
    return $group
}

function New-SecGroup {
    param(
        [string] $GroupName
    )

    try {
        $newGroup = New-MgGroup `
            -DisplayName $GroupName `
            -MailEnabled:$false `
            -MailNickname ($GroupName -replace '\s','') `
            -SecurityEnabled:$true

        Write-Host "[Created] Group: $($newGroup.DisplayName) ($($newGroup.Id))" -ForegroundColor Green

        $script:SecGroupCache += $newGroup
        return $newGroup | Select-Object Id
    }
    catch {
        Write-Host "[Error] Failed to create group: $_" -ForegroundColor Red
        return $null
    }
}

function GetOrCreate-SecGroup {
    param(
        [string] $GroupName
    )

    $group = Get-SecGroup -GroupName $GroupName

    if ($group) {
        Write-Host "[Ok] Found group in cache: $($group.DisplayName)" -ForegroundColor Green
        return $group
    }
    else {
        Write-Host "(!) Group not found: $GroupName" -ForegroundColor Yellow
        $choice = Read-Host "Do you want to create it? (Y/N)"
        if ($choice -match '^(Y|y)') {
            return New-SecGroup -GroupName $GroupName 
        }
        else {
            Write-Host "[Skipped] Group not created." -ForegroundColor DarkGray
            return $null
        }
    }
}

function Copy-EntraGroup {
    <#
    .SYNOPSIS
        Clone an Entra ID (Azure AD) group including all active users and nested groups.

    .DESCRIPTION
        This function:
        - Connects to Microsoft Graph (requires Microsoft.Graph module)
        - Gets the source group
        - Summarizes members (active users + groups)
        - Prompts for confirmation
        - Creates a new group
        - Adds members (users + groups)

    .PARAMETER SourceGroupId
        The ObjectId (GUID) of the group you want to copy.

    .PARAMETER NewGroupDisplayName
        Optional. Custom display name for the new group.
        If not provided, "- Copy" will be appended to the source name.
    #>

    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [string]$SourceGroupId,
        [string]$NewGroupDisplayName
    )

    begin {
        $scopes = @("Group.ReadWrite.All", "User.Read.All", "Directory.Read.All")
        Connect-MgGraph -Scopes $scopes -NoWelcome
    }

    process {
        # Get source group
        $sourceGroup = Get-MgGroup -GroupId $SourceGroupId -Property DisplayName, Description, MailNickname, GroupTypes

        if (-not $sourceGroup) {
            Write-Error "Source group not found."
            return
        }

        # Generate new group name
        if (-not $NewGroupDisplayName) {
            $NewGroupDisplayName = "$($sourceGroup.DisplayName) - Copy"
        }

        $members = Get-MgGroupMember -GroupId $SourceGroupId -All

        Write-Host "Source group : $($sourceGroup.DisplayName) [$SourceGroupId]" -ForegroundColor Cyan
        Write-Host "New group    : $NewGroupDisplayName" -ForegroundColor Cyan
        Write-Host "members to copy : $($members.Count)" -ForegroundColor Green

        $choice = Read-Host "Do you want to continue? (Y/N)"
        if ($choice -notin @('Y','y')) {
            Write-Host "Operation cancelled." -ForegroundColor Yellow
            return
        }

        # Create new group
        $newGroupParams = @{
            DisplayName     = $NewGroupDisplayName
            MailEnabled     = $false
            MailNickname    = "$($sourceGroup.MailNickname)-copy"
            SecurityEnabled = $true
            Description     = "Copy of group '$($sourceGroup.DisplayName)'"
            GroupTypes      = $sourceGroup.GroupTypes
        }
        $newGroup = New-MgGroup @newGroupParams

        Write-Host "Created new group: $($newGroup.DisplayName) [$($newGroup.Id)]" -ForegroundColor Green

        # Add users
        foreach ($m in $members) {
            try {
                New-MgGroupMember -GroupId $newGroup.Id -DirectoryObjectId $m.Id -ErrorAction Stop
                Write-Host "Added member : $m.Id" -ForegroundColor Cyan
            }
            catch {
                Write-Warning "Failed to add member $($m.Id): $_"
            }
        }


        Write-Host "✅ Group clone complete!" -ForegroundColor Green
    }
}


Register-GroupCompleter -CommandName GetOrCreate-SecGroup -ParameterName GroupName
Register-GroupCompleter -CommandName Get-Group -ParameterName GroupName              
Register-GroupCompleter -CommandName New-SecGroup -ParameterName GroupName  