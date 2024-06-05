<# 
.SYNOPSIS AND DESCRIPTION 
    A common reason for MEM Apps to fail is Error downloading content. (0x87D30068). The problem is that IME doesn't retry for 24 hours. This script will force a retry by deleting key registry items.

.NOTES 
    This is an expermental script. -WhatIf parameters are still on it is recommended this script is tried on a few target endpoints and the whatif outputs are observed so that no other extra registry items will be removed.
    To find the AppId of the app you need to retry, go to the end of the url of the app in MEM

.COMPONENT 
    Information about PowerShell Modules to be required.

.LINK 
    This article contains deeper information about the retry problem https://call4cloud.nl/2022/07/retry-lola-retry/#part1-3
 
#>

$appid = "<ENTER YOUR APPID HERE>"

#1 Delete Keys in \SideCarPolicies\StatusServiceReports
$statusServiceReportKeys = Get-ChildItem -Path "HKLM:\SOFTWARE\Microsoft\IntuneManagementExtension\SideCarPolicies\StatusServiceReports"
foreach ($statusServiceReportKey in $statusServiceReportKeys)
{
    $targetSubKey = ""
    $keyChildName = $statusServiceReportKey.PSChildName
    $targetSubKeys = Get-ChildItem -Path "HKLM:\SOFTWARE\Microsoft\IntuneManagementExtension\SideCarPolicies\StatusServiceReports\$keyChildName" | Where-Object {$_.PSChildName -like "$appid*"}
    foreach ($targetSubKey in $targetSubKeys)
    {
    #write $targetSubKey.PSPath
    Remove-Item $targetSubKey.PSPath -Recurse -Force -WhatIf
    }
}

$win32AppKeys = Get-ChildItem -Path "HKLM:\SOFTWARE\Microsoft\IntuneManagementExtension\Win32Apps" | Where-Object {($_.PSChildName -ne "OperationalState" -and $_.PSChildName -ne "Reporting")}
foreach ($win32AppKey in $win32AppKeys)
{
    $targetSubKey = ""
    #2 Delete Keys in Win32Apps
    $keyChildName = $win32AppKey.PSChildName
    $targetSubKeys = Get-ChildItem -Path "HKLM:\SOFTWARE\Microsoft\IntuneManagementExtension\Win32Apps\$keyChildName" | Where-Object {$_.PSChildName -like "$appid*"}
    foreach ($targetSubKey in $targetSubKeys)
    {
    #write $targetSubKey.PSPath
    Remove-Item $targetSubKey.PSPath -Recurse -Force -WhatIf
    }

    #3 Delete Key in GRS
    $GRSkeys = Get-ChildItem -Path "HKLM:\SOFTWARE\Microsoft\IntuneManagementExtension\Win32Apps\$keyChildName\GRS"
    foreach ($GRSKey in $GRSkeys)
    {
        $GRSKeyPath = $GRSKey.PSPath
        if((Get-ItemProperty $GRSKeyPath).PSObject.Properties.Name -contains $appid)
        {
            Remove-Item $GRSKeyPath -Force -WhatIf
        }
    }
}
