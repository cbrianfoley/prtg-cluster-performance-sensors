<#
prtg-storagejobstatus-sensor.ps1
Powershell script to return storage job status in PRTG format

.USAGE
 1. Update this script and put a copy for each StorageJobHost in the PRTG Network Monitor\Custom Sensors\EXEXML folder.

        Set StorageJobHost to the hostname of one of the cluster storage servers. 

 2.	Add an EXE Advanced sensor in PRTG
	    Be sure to select the correct script under Sensor Settings -> Exe/Script
	Select 'Use Windows Credentials of parent device' and make sure that account credentials are put in the parent group.

#>

# -----------------------

$StorageJobHost = "StorageHost01" # EDIT THIS LINE

# -----------------------

$StorageJobStatus = Invoke-Command -ComputerName $StorageJobHost -ScriptBlock { Get-StorageJob }


$xmlstring = "<?xml version=`"1.0`"?>`n    <prtg>`n"
$xmlstring += "        <result>`n"
$xmlstring += "        <channel>StorageJobStatus</channel>`n"
$xmlstring += "        <value>$(IF ($StorageJobStatus -eq $null){"0"} ELSE {"4"})</value>`n"
$xmlstring += "        <LimitMaxWarning>1</LimitMaxWarning>`n"
$xmlstring += "        <LimitWarningMsg>There is a StorageJob running called $($StorageJobStatus.Name). $($StorageJobStatus.PercentComplete) percent complete</LimitWarningMsg>`n"
$xmlstring += "        <text>$($StorageJobStatus.Name) $($StorageJobStatus.PercentComplete) percent complete</text>`n"
$xmlstring += "        </result>`n"
$xmlstring += "    </prtg>"

Write-Host $xmlstring