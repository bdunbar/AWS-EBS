Import-Module  (Join-Path $env:SystemDrive '\Program Files (x86)\AWS Tools\PowerShell\AWSPowerShell\AWSPowerShell.psd1')
$AKey = 'YOUR_ACCESS_KEY'
$SKey = 'YOUR_SECRET_KEY'
$DRegion = 'YOUR_REGION'
#END Import & Set Default Configuration
Set-AWSCredentials -AccessKey $AKey -SecretKey $SKey
Set-DefaultAWSRegion $DRegion