# Create certificate
$mycert = New-SelfSignedCertificate -FriendlyName "AzureAutomation_RESOURCEGROUP_rg_SPOAccess" -NotAfter (Get-Date).AddYears(1) `
-DnsName "kion.microsoft.com" -Subject "AAD Cert Auth" -CertStoreLocation "cert:\CurrentUser\My" -KeySpec KeyExchange

# Export certificate to .pfx file
$mycert | Export-PfxCertificate -FilePath C:\repos\certs\AzureAutomation_RESOURCEGROUP_rg_SPOAccess.pfx -Password $(ConvertTo-SecureString -String "PASSWORD" -AsPlainText -Force)
 
# Export certificate to .cer file
$mycert | Export-Certificate -FilePath C:\repos\certs\AzureAutomation_RESOURCEGROUP_rg_SPOAccess.cer
