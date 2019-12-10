<#
prtg-physicaldisk-sensor.ps1
Powershell script to return cluster disk health in PRTG format

.USAGE
 1. Update this script and put a copy for each StorageHost in the PRTG Network Monitor\Custom Sensors\EXEXML folder.

        Set DiskHost to the hostname of one of the cluster storage servers. 

 2.	Add an EXE Advanced sensor in PRTG
	    Be sure to select the correct script under Sensor Settings -> Exe/Script
	Select 'Use Windows Credentials of parent device' and make sure that account credentials are put in the parent group.

#>

# -----------------------

$DiskHost = 'StorageHost01' # EDIT THIS LINE

# -----------------------

$Disks = Get-PhysicalDisk -CimSession $DiskHost

$xmlstring = "<?xml version=`"1.0`"?>`n    <prtg>`n"

ForEach ($disk IN $Disks) {

$xmlstring += "        <result>`n"
$xmlstring += "        <channel>$($disk.SerialNumber) Health (0 means Healthy)</channel>`n"
$xmlstring += "        <value>$(IF ($disk.HealthStatus -eq 'Healthy'){"0"} ELSE {"4"})</value>`n"
$xmlstring += "        <LimitMaxError>1</LimitMaxError>`n"
$xmlstring += "        <LimitErrorMsg>The result of Get-PhysicalDisk Health status is $($disk.HealthStatus)</LimitErrorMsg>`n"
$xmlstring += "        <text>$($disk.HealthStatus)</text>`n"
$xmlstring += "        </result>`n"
$xmlstring += "        <result>`n"
$xmlstring += "        <channel>$($disk.SerialNumber) OperationalStatus (0 means OK)</channel>`n"
$xmlstring += "        <value>$(IF ($disk.OperationalStatus -eq 'OK'){"0"} ELSE {"4"})</value>`n"
$xmlstring += "        <LimitMaxError>1</LimitMaxError>`n"
$xmlstring += "        <LimitErrorMsg>The result of Get-PhysicalDisk OperationalStatus is $($disk.OperationalStatus)</LimitErrorMsg>`n"
$xmlstring += "        <text>$($disk.OperationalStatus)</text>`n"
$xmlstring += "        </result>`n"
 }

$xmlstring += "    </prtg>"

Write-Host $xmlstring