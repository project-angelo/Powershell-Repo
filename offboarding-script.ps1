# Start sessions
Connect-ExchangeOnline -ShowBanner:$false

# Connect to Microsoft Graph (with required scopes)
Connect-MgGraph -Scopes 'User.ReadWrite.All','Group.ReadWrite.All','Directory.ReadWrite.All'
Select-MgProfile -Name 'v1.0'

# Declare variables
$UserPrincipalName = "laura.barron@daborragroup.com"
$user = Get-MgUser -UserId $UserPrincipalName -ErrorAction Stop
$userId = $user.Id

# Hide from GAL
Set-Mailbox -Identity $UserPrincipalName -HiddenFromAddressListsEnabled $true

# Remove user from all (direct) group memberships
Get-MgUserMemberOf -UserId $userId -All |
  Where-Object { $_.AdditionalProperties.'@odata.type' -eq '#microsoft.graph.group' } |
  ForEach-Object {
    Remove-MgGroupMemberByRef -GroupId $_.Id -DirectoryObjectId $userId -ErrorAction SilentlyContinue
  }

# Block sign-in
Update-MgUser -UserId $UserPrincipalName -AccountEnabled:$false

# Convert to shared mailbox (before license removal)
Set-Mailbox -Identity $UserPrincipalName -Type Shared

# Remove all licenses
Set-MgUserLicense -UserId $UserPrincipalName -AddLicenses @() -RemoveLicenses (Get-MgUserLicenseDetail -UserId $UserPrincipalName).SkuId

# (Optional) Reset password properly (set a value) OR just remove the prompt
# -- To set a new password and not force change:
# Update-MgUser -UserId $UserPrincipalName -PasswordProfile @{ password = 'NewStr0ng!Pass'; forceChangePasswordNextSignIn = $false }

# -- If you only want to remove the "must change at next sign-in" flag (no password change):
Update-MgUser -UserId $UserPrincipalName -PasswordProfile @{ forceChangePasswordNextSignIn = $false }

# (Optional) Disconnects
# Disconnect-ExchangeOnline -Confirm:$false
# Disconnect-MgGraph

Disconnect-ExchangeOnline
Disconnect-MgGraph