<#
prtg-cluster-sensor.ps1
Powershell script to return storage pool health status in PRTG format

.USAGE
 1. Update this script and put a copy for each StorageHost in the PRTG Network Monitor\Custom Sensors\EXEXML folder.

        Set StorageHost to the hostname of one of the cluster storage servers 

 2.	Add an EXE Advanced sensor in PRTG
	    Be sure to select the correct script under Sensor Settings -> Exe/Script
	Select 'Use Windows Credentials of parent device' and make sure that account credentials are put in the parent group.

#>

# -----------------------

$StorageHost = 'StorageHost01' # EDIT THIS LINE

# -----------------------

$StoragePool = Get-StoragePool -FriendlyName "S2D*" -CimSession $StorageHost

$xmlstring = "<?xml version=`"1.0`"?>`n    <prtg>`n"

ForEach ($pool IN $StoragePool) {

$xmlstring += "        <result>`n"
$xmlstring += "        <channel>Health of $($pool.FriendlyName) (0 means Healthy)</channel>`n"
$xmlstring += "        <value>$(IF ($pool.HealthStatus -eq 'Healthy'){"0"} ELSE {"4"})</value>`n"
$xmlstring += "        <LimitMode>1</LimitMode>`n"
$xmlstring += "        <LimitMaxError>1</LimitMaxError>`n"
$xmlstring += "        <LimitErrorMsg>The result of Get-StoragePool Health status is $($pool.HealthStatus)</LimitErrorMsg>`n"
$xmlstring += "        <text>$($pool.HealthStatus)</text>`n"
$xmlstring += "        </result>`n"
$xmlstring += "        <result>`n"
$xmlstring += "        <channel>OperationalStatus of $($pool.FriendlyName) (0 means OK)</channel>`n"
$xmlstring += "        <value>$(IF ($pool.OperationalStatus -eq 'OK'){"0"} ELSE {"4"})</value>`n"
$xmlstring += "        <LimitMode>1</LimitMode>`n"
$xmlstring += "        <LimitMaxError>1</LimitMaxError>`n"
$xmlstring += "        <LimitErrorMsg>The result of Get-StoragePoll OperationalStatus status is $($pool.OperationalStatus)</LimitErrorMsg>`n"
$xmlstring += "        <text>$($pool.OperationalStatus)</text>`n"
$xmlstring += "        </result>`n"

 }

$xmlstring += "    </prtg>"

Write-Host $xmlstring