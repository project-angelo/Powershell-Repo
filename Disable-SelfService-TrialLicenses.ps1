# 1. Install module silently - bypass untrusted repo prompt
Install-Module -Name MSCommerce -Force -AllowClobber -Repository PSGallery -Scope CurrentUser

# 2. Import module
Import-Module MSCommerce

# 3. Connect to tenant (this will still prompt for login - cannot bypass MFA)
Connect-MSCommerce

# 4. View all current policies
Get-MSCommerceProductPolicies -PolicyId AllowSelfServicePurchase

# 5. Disable ALL self-service purchases at once
Get-MSCommerceProductPolicies -PolicyId AllowSelfServicePurchase | ForEach-Object {
    Update-MSCommerceProductPolicy `
        -PolicyId AllowSelfServicePurchase `
        -ProductId $_.ProductId `
        -Enabled $false
}

# 6. Verify all are now blocked
Get-MSCommerceProductPolicies -PolicyId AllowSelfServicePurchase