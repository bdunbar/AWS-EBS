#Description: Export Log
function WriteLog ([string] $fLogTxt, [string] $fErrorType )
{
    #Add-Content $logfileName $fLogTxt
    If($fErrorType -eq "Info"){$fColour="Yellow"}
    If($fErrorType -eq "Success"){$fColour="Green"}
    If($fErrorType -eq "Error"){$fColour="Red"}

    If($fErrorType -eq ""){$fColour="White"}

    Write-Host -foregroundcolor $fColour $fLogTxt
}

#Description: Simple Write TAG
function WriteTag([string] $fResourceID, [string] $fTagKey, [string] $fTagValue)
{
    try
    {
        $fTag = New-Object Amazon.EC2.Model.Tag
        $fTag.Key = $fTagKey
        $fTag.Value = $fTagValue
        New-EC2Tag -ResourceId $fResourceID -Tag $fTag
        return
    }
    catch [Exception]
    {
        $function = "WriteTag"
        $exception = $_.Exception.ToString()
        WriteLog "$function : $exception" "Error"
        return $null
    }
}

#Description: Before executing command retry AWS Connection if failed
#Returns: Result
function Execute-Command($Command, $CommandName, [string] $MaxRetryCount, [string] $RetryTimeOut) {
    $currentRetry = 1;
    $retrying = $true;
    do {
        try
        {
            $result=& $Command
            $retrying = $false
            WriteLog "Successfully executed $CommandName command. Number of tries : $currentRetry";
            return $result
        }
        catch [System.Exception]
        {
            $exception = $_.Exception.ToString()
            $message = "Exception occurred while trying to execute '$CommandName' command:" + $_.Exception.ToString();
            if ($currentRetry -gt $MaxRetryCount) {
                WriteLog "$CommandName : $exception" "Error"
                return $null
                $retrying = $false
            } else {
                WriteLog "$CommandName : $exception" "Error"
                WriteLog "Failed running '$CommandName' ... retrying for the $currentRetry time" "Info"
                Start-Sleep -s $RetryTimeOut;
            }
            $currentRetry = $currentRetry + 1;
        }
    } while ($retrying);
}

#Description: AWS Connection retry
#Returns: Result
function AWSRetry([string] $TryCount, [string] $TimeToWait)
{
    $Stoploop = $false
    [int]$Retrycount = "0"
    do
        {
        try
        {
            $GetConn = (Get-EC2Instance).Count
            Write-Host "Connected to AWS successfully!!"
            $Stoploop = $true
        }
    catch
        {
            if ($Retrycount -eq $TryCount)
                {
                    Write-Host "Unable to connect AWS after",$TryCount,"retrys."
                    Exit
                    $Stoploop = $true
                }
            else
                {
                    Write-Host "Unable to connect AWS, retrying in",$TimeToWait,"seconds..."
                    Start-Sleep -Seconds $TimeToWait
                    $Retrycount = $Retrycount + 1
                }
        }
    }
        While ($Stoploop -eq $false)
}
