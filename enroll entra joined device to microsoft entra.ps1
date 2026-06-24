# Verify MdmUrl is set (already confirmed from dsregcmd)
$MDMUrl = (Get-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Enrollments\*" -ErrorAction SilentlyContinue).MDMServiceUrl

# Create Scheduled Task to run as SYSTEM
$Action = New-ScheduledTaskAction -Execute "$env:windir\system32\deviceenroller.exe" -Argument "/c /AutoEnrollMDM"
$Trigger = New-ScheduledTaskTrigger -At (Get-Date).AddSeconds(15) -Once
$Settings = New-ScheduledTaskSettingsSet -ExecutionTimeLimit (New-TimeSpan -Minutes 5)

Register-ScheduledTask -TaskName "TriggerIntuneEnrollment" `
    -Action $Action `
    -Trigger $Trigger `
    -User "SYSTEM" `
    -Settings $Settings `
    -Force

Start-ScheduledTask -TaskName "TriggerIntuneEnrollment"
Write-Output "Enrollment task triggered. Waiting..."

# Wait and check result
Start-Sleep -Seconds 60

# Check Event Log for result
Get-WinEvent -LogName "Microsoft-Windows-DeviceManagement-Enterprise-Diagnostics-Provider/Admin" -MaxEvents 20 |
    Where-Object { $_.Id -eq 75 -or $_.Id -eq 76 } |
    Select-Object TimeCreated, Id, Message |
    Format-List

# Cleanup
Unregister-ScheduledTask -TaskName "TriggerIntuneEnrollment" -Confirm:$false

#verify it worked
dsregcmd /status | Select-String "MDM"