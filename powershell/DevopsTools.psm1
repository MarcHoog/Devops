# Import all scripts in the module

# IIS scripts
. $PSScriptRoot/src/iis/iis_copy_site.ps1
. $PSScriptRoot/src/iis/iis_paste_site.ps1
. $PSScriptRoot/src/iis/iis_wacs_quick_cert.ps1
. $PSScriptRoot/src/iis/install_iis_role.ps1

# RDP scripts
. $PSScriptRoot/src/rdp/setup_local_rdp.ps1

# SSH scripts
. $PSScriptRoot/src/ssh/install_ssh_server.ps1
. $PSScriptRoot/src/ssh/installing_ssh.ps1

# Winget scripts
. $PSScriptRoot/src/winget/installing_winget.ps1

# RBAC scripts
. $PSScriptRoot/src/rbac/rbac_acces_matrix_acces_packages.ps1

# Entra scripts
. $PSScriptRoot/src/entra/entra_access_matrix.ps1