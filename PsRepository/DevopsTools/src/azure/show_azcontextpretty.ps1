function Show-AzContextPretty {
    $ctx = Get-AzContext
    if (-not $ctx) {
        Write-Host "No active Az context." -ForegroundColor Red
        return
    }

    $tenantName  = $ctx.Tenant.Id
    $subName     = $ctx.Subscription.Name
    $subId       = $ctx.Subscription.Id
    $account     = $ctx.Account.Id

    $banner = @"
         _             _           _                  _           _      
        / /\         /\ \         /\_\               /\ \        /\ \    
       / /  \       /  \ \       / / /         _    /  \ \      /  \ \   
      / / /\ \   __/ /\ \ \      \ \ \__      /\_\ / /\ \ \    / /\ \ \  
     / / /\ \ \ /___/ /\ \ \      \ \___\    / / // / /\ \_\  / / /\ \_\ 
    / / /  \ \ \\___\/ / / /       \__  /   / / // / /_/ / / / /_/_ \/_/ 
   / / /___/ /\ \     / / /        / / /   / / // / /__\/ / / /____/\    
  / / /_____/ /\ \   / / /    _   / / /   / / // / /_____/ / /\____\/    
 / /_________/\ \ \  \ \ \__/\_\ / / /___/ / // / /\ \ \  / / /______    
/ / /_       __\ \_\  \ \___\/ // / /____\/ // / /  \ \ \/ / /_______\   
\_\___\     /____/_/   \/___/_/ \/_________/ \/_/    \_\/\/__________/   
                                                                         
"@

    Write-Host $banner -ForegroundColor Cyan
    Write-Host  "Account     : $account"     -ForegroundColor Green
    Write-Host  "Tenant      : $tenantName"  -ForegroundColor Green
    Write-Host  "Subscription: $subName ($subId)" -ForegroundColor Green
    Write-Host ""
}
