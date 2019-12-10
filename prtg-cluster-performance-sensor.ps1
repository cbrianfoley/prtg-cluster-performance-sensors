<#

prtg-cluster-performance-sensor.ps1
Note this will only work if your storage servers are Server 2019 (Get-Clusterperformancehistory is used)

.USAGE
Steps
1.	Install Hyper-V tools and failover clustering features on the probe server if it isn’t already (elevated powershell command): 

        Install-WindowsFeature -Name RSAT-Hyper-V-Tools –IncludeAllSubFeature
        Install-WindowsFeature -Name RSAT-Clustering

2.	Make the 32 AND 64 bit version of PowerShell ‘RemoteSigned’ on the probe server (elevated powershell command):

        %SystemRoot%\SysWOW64\WindowsPowerShell\v1.0\powershell.exe "Set-ExecutionPolicy RemoteSigned"
        %SystemRoot%\System32\WindowsPowerShell\v1.0\powershell.exe "Set-ExecutionPolicy RemoteSigned"

3.	Add service account as a member of the group Hyper-V Administrators on each host 
        
        (this might be unnecessary if service account is a domain admin)

4.	Update this script and put a copy in the PRTG Network Monitor\Custom Sensors folder.

        Set ClusterName to the name of your cluster to be monitored 

5.  Due to how PRTG behaves, it can only call the 32 bit version of powershell, so we have to cheat/wrapper. Create a new .ps1 script with only one line that will call this script
        
        C:\windows\sysnative\windowspowershell\v1.0\powershell.exe -file "C:\Program Files (x86)\PRTG Network Monitor\Custom Sensors\EXEXML\prtg-cluster-performance-sensor.ps1"

6.	Add a custom EXE Advanced sensor in PRTG
        Be sure to select the correct script under Sensor Settings -> Exe/Script (we are selecting the wrapper one-liner)
	    Select 'Use Windows Credentials of parent device' and make sure that account credentials are put in the parent group.

#>

# -----------------------

$ClusterName = "Cluster01-19" # EDIT THIS LINE

# -----------------------
Import-Module FailoverClusters

$ClusterNodes = (Get-Cluster -Name $ClusterName | Get-ClusterNode)

# begin our xml file header
$xmlstring = "<?xml version=`"1.0`"?>`n"
$xmlstring += "    <prtg>`n"

# this does ask each node in the cluster for performance statistics, even though they all will report the same value. You could remove the for-loop and just ask a single node for a performance benefit
ForEach ($node IN $ClusterNodes) {

    $PerfHistory = Invoke-Command -ComputerName $node -ScriptBlock {Get-Clusterperformancehistory} | Select MetricID,Value | 
        Where {($_.MetricId -match "Volume.IOPS") -or ($_.MetricId -match "Volume.Latency")}

    ForEach ($metric in $PerfHistory) {
        $xmlstring += "    <result>`n"
        $xmlstring += "        <channel>$($metric.MetricID)</channel>`n"
        $xmlstring += "        <unit>Custom</unit>`n"
        $xmlstring += "        <mode>Absolute</mode>`n"
        $xmlstring += "        <showChart>1</showChart>`n"
        $xmlstring += "        <showTable>1</showTable>`n"
        $xmlstring += "        <float>1</float>`n"
        $xmlstring += "        <value>$($metric.Value)</value>`n"
        $xmlstring += "        <LimitMode>1</LimitMode>`n"
        $xmlstring += "    </result>`n"
    }
}
$xmlstring += "    </prtg>"

Write-Host $xmlstring