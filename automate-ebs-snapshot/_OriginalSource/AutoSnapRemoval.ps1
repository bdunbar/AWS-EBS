############################################################################# 
# 
# NAME: AutoSnap Removal for AWS EC2 SnapShots
# 
# AUTHOR: Saugata Datta 
# Date: Jan 24, 2014
# 
# ABOUT:  This Script will delete the old snapshot those are created by 
#         'AutoSnap Creation for AWS EC2 Volumes' as per configured retention
#         period. This script will trigger one email after completion.
#         Email will contain the details for all deleted snapshot.
#############################################################################
#START Import & Set Default Configuration
. "$PSScriptRoot\Config\AWSConfig.ps1"
. "$PSScriptRoot\Config\AWSTools.ps1"
#Backup retention period (Days)
$Retention = "7"
#Set DAILY, WEEKLY, MONTHLY etc.
$SnapType = "DAILY"
$OldDate = (Get-Date).AddDays(-$Retention)
$OldSnapDate = $SnapType,"_",$OldDate.Month,"-",$OldDate.Day,"-",$OldDate.Year -join ""
$SnaidsX = Get-EC2Snapshot | ? {$_.Description -like "*$OldSnapDate*"} | select SnapshotId
$Snapids = $SnaidsX.SnapshotId
If ($Snapids.Count -ne 0)
{
    $body = @()
    $body += "Hi, Gents!"
    $body += $Snapids.Count," expired ",$SnapType," snapshots (",$Retention," Days old) are deleted successfully." -join ""
    foreach ($Snapid in $Snapids)
    {
        $body += Get-EC2Snapshot -SnapshotId $Snapid | Select Description
        #Careful with removing snapshot, test before implement in production
        $RemoveSnap = { Remove-EC2Snapshot -SnapshotId $Snapid -Force }
        $CmdName = "Remove EC2 SnapShot"
        $DSnapExeC = Execute-Command -Command $RemoveSnap -CommandName $cmdName 20 30
        
    }
    $body += ""
    $body += "Regards,"
    $body += "Server Team."
    $body = $body | out-string
    $NotiEmail = @{
	#Email Configuration
    From = "FROM@DOMAIN.COM"
    To = "TO1@DOMAIN.COM", "TO2@DOMAIN.COM"
    Subject = "~AWS EC2~ Auto SnapShot (",$SnapType,") Creation Status" -join ""
    SMTPServer = "SMTP.DOMAIN.COM"
    Priority = "High"
    Body = $body
    }
    Send-MailMessage @NotiEmail
}
ElseIf ($Snapids.Count -eq 0) {Write-Host "No old SnapShots found!!"}