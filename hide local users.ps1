# List of local usernames to hide
$UsersToHide = @("User1","User2")   # <-- change these usernames
 
# Registry path
$RegPath = "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon\SpecialAccounts\UserList"
 
# Create the key if it doesn't exist
if (!(Test-Path $RegPath)) {
    New-Item -Path $RegPath -Force | Out-Null
}
 
# Hide users (0 = hidden, 1 = visible)
foreach ($User in $UsersToHide) {
    New-ItemProperty -Path $RegPath -Name $User -Value 0 -PropertyType DWORD -Force | Out-Null
}
 
Write-Host "Specified users are now hidden from the logon screen."