# Get details on all your EBS Volumes

Get-EC2Volume | Format-Table -AutoSize

# Export details of EBS Volumes to CSV
# You need to use the Convert-OutputForCSV.ps1 function (load first)

$CSV = "C:\Temp\EBSVolumes.csv"
. .\Convert-OutputForCSV.ps1
Get-EC2Volume | Convert-OutputForCSV | Export-CSV $CSV -NoTypeInformation

# 