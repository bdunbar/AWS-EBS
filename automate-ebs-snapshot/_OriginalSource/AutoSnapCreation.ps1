############################################################################## 
# 
# NAME: AutoSnap Creation for AWS EC2 Volumes - All or Attached or Available
# 
# AUTHOR: Saugata Datta 
# Date: Jan 24, 2014
# 
# ABOUT:  This Script will automate the snapshot process of your EC2 Volumes.
#         This script can be configured totake the backup for all volumes or
#         attached volumes or Available volumes. After taking the backup, this
#         script will trigger one email after completion. Email will contain
#         the details for all new snapshot taken by this script.
############################################################################## 
#START Import & Set Default Configuration
. "$PSScriptRoot\Config\AWSConfig.ps1"
. "$PSScriptRoot\Config\AWSTools.ps1"
AWSRetry 30 30
######### VOLUME CONFIGURATION START #########
#Testing with single volume
#$TestVol = Get-EC2Volume | ? {$_.VolumeId -eq 'vol-xxxxxxxx'}
#$Volids = $TestVol.VolumeId
#For only free volumes
#$VolFree = Get-EC2Volume | ? {$_.Status -eq 'available'}
#$Volids = $VolFree.VolumeId
#For only active volumes
#$VolInUse = Get-EC2Volume | ? {$_.Status -eq 'in-use'}
#$Volids = $VolInUse.VolumeId
#For only Root Volumes
#$RootVol = (Get-EC2Volume).Attachment | ? {$_.Device -eq '/dev/sda1'}
#$Volids = $RootVol.VolumeId
#For all volumes
$Volids = (Get-EC2Volume).VolumeId
######### VOLUME CONFIGURATION END #########
$DateVar = Get-Date -format M-d-yyyy
$DayVar = (get-date).DayOfWeek
#Don't forget to add \ in end.
$LogPath = "$PSScriptRoot\Dailylog\"
#Set DAILY, WEEKLY, MONTHLY etc.
$SnapType = "DAILY"
$SnapLogs = $LogPath,$DayVar,"_",$SnapType,"_",$DateVar,".log" -join ""
$MiniSnapDes = "_AutoSnap_",$SnapType,"_",$DateVar -join ""
$VolCount = (Get-EC2Volume).Count
$SnapCount = (Get-EC2Snapshot | ? {$_.Description -like "*$MiniSnapDes*"}).Count
If ($VolCount -ne 0 -AND $SnapCount -eq 0)
{
    foreach ($Volid in $Volids)
    {
        $FullSnapDes = $Volid,$MiniSnapDes -join ""
        $TakeSnap = { New-EC2Snapshot -VolumeId $Volid -Description $FullSnapDes | select VolumeId,SnapshotId,Description }
        $CmdName = "Take EC2 SnapShot"
        $CSnapExeC = Execute-Command -Command $TakeSnap -CommandName $cmdName 20 30
        $GetResource = (Get-EC2Snapshot | ? {$_.Description -eq "$FullSnapDes"}).SnapshotId
        $GetIns = ((Get-EC2Volume).Attachment | ? {$_.VolumeId -eq "$Volid"}).InstanceId
        $GetDevice = ((Get-EC2Volume).Attachment | ? {$_.VolumeId -eq "$Volid"}).Device
        $GetName = Get-EC2Tag | ? {$_.ResourceId -eq "$GetIns" -AND $_.Key -eq 'Name'}
        If ($GetName.Count -ne 0)
        {
            $Value = $GetName.Value,"(",$Volid,")" -join ""
            WriteTag $GetResource 'Name' $Value
            WriteTag $GetResource 'BlockDevice' $GetDevice
        }
        Else
        {
            WriteTag $GetResource 'Name' 'No Attachment'
            WriteTag $GetResource 'BlockDevice' 'None'
        }
    }
    $NewSnaps = Get-EC2Snapshot | ? {$_.Description -like "*$MiniSnapDes*"}
    $NewSnaps | select VolumeId,SnapshotId,Description | Format-Table -AutoSize | Out-File -FilePath $SnapLogs -Encoding Ascii
    $body = @()
    $body += "Hi, Gents!"
    $body += $NewSnaps.Count," ",$SnapType," SnapShots are successfully taken for ",$VolCount," volumes with following description." -join ""
    $body += Get-EC2Snapshot | ? {$_.Description -like "*$MiniSnapDes*"} | select Description | Format-Table -AutoSize
    $body += "Regards,"
    $body += "Server Team."
    $body = $body | Out-String
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
ElseIf ($VolCount -eq 0 -OR $SnapCount -ne 0) {Write-Host "Snapshots are already taken or No volumes available!!"}