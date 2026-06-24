# Define the Distribution List Email
$group = "your-dl@yourdomain.com"

# Import CSV file
$users = Import-Csv "C:\users.csv"

# Connect to Exchange Online
Connect-ExchangeOnline -UserPrincipalName youradmin@yourdomain.com

# Add each user to the Distribution List
foreach ($user in $users) {
    try {
        Add-DistributionGroupMember -Identity $group -Member $user.EmailAddress
        Write-Host "Added $($user.EmailAddress) to $group" -ForegroundColor Green
    } catch {
        Write-Warning "Failed to add $($user.EmailAddress): $_"
    }
}

# Disconnect
Disconnect-ExchangeOnline
