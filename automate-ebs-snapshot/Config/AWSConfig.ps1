Import-Module  (Join-Path $env:SystemDrive '\Program Files (x86)\AWS Tools\PowerShell\AWSPowerShell\AWSPowerShell.psd1')
$AKey = 'AKIAJ2BFLJAQDC6SXNMA'
$SKey = 'B26hc8GUPIfrRA4+dGFrJot1xb1UoSHmVVUfUKGK'
$DRegion = 'eu-west-1'
#END Import & Set Default Configuration
Set-AWSCredentials -AccessKey $AKey -SecretKey $SKey
Set-DefaultAWSRegion $DRegion