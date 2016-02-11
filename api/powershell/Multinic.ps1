#  Script name:   CreateServersFromCSV.ps1
#  Version:       1.0
#  Created on:    2/1/2016
#  Author:        Jake Malmad
#  Purpose:       Connects to CLC cloud via API to add multiple nics to servers. Prompts for acct/servername but needs API creds.
#  History:       
#     
#Set version of powershell incase client is using Powershell v4 (the following line needs #)
#Requires -Version 3

#Change variables to match your user API key and password - V1
[String]$APIKey = "54ed37593bd74fd099d5de1c3a7d8479"
[String]$APIPassword = "{N]hl61DEs?x45g-"

#Change variables to match your user portal username and password - V2
[String]$username = "jmalmad.ctlc"
[String]$password = ""

#Globally used variables
$scriptpath = Split-Path $MyInvocation.MyCommand.Path

#Configure logging
cd c:\
$Logfile = "$scriptpath\CreateServersLog.txt"

#Create logfile
if(Test-Path $Logfile)
{
    Out-File -inputObject $_ -append -filepath $Logfile
}
else
{
    new-item -force -path $Logfile -value $_ -type file
}

#Functions
Function LogWrite($string, $color)
{
   if ($color -eq $null) {$color = "white"}

   #Append date / time
   $string = $(Get-Date –f o) + "     " + $string

   #Write to screen
   write-host $string -foregroundcolor $color

   #Write to log
   $string | out-file -Filepath $LogFile -append
}

#Login to API - V1
$Result = Invoke-RestMethod -URI "https://api.ctl.io/REST/Auth/Logon" -Method POST -ContentType application/json -Body "{'APIKey':  '$APIKey', 'Password':  '$APIPassword'}" -SessionVariable session
LogWrite $Result | fl

#Login to API - V2
$Result = Invoke-RestMethod -URI 'https://api.ctl.io/v2/authentication/login' -Method POST -ContentType application/json -Body "{'username':'$username', 'password':'$password'}" -verbose
$BearerToken = "Bearer " + $Result.bearerToken.ToString()
LogWrite $Result | FL

#Get Variables
$AcctAlias = Read-Host -Prompt 'Input the Server acct alias:'
$ServerID = Read-Host -Prompt 'Input the Server ID/name:'
$Network = Read-Host -Prompt 'Input the Network ID:'
$ipAddress = Read-Host -Prompt 'Input the IP Address:'

    #Add NIC
    LogWrite "Adding NIC from $Network to $ServerID"
    $NetworkInfo = "{'networkID':'$Network','ipAddress':'$ipAddress'}"
    $RequestURL = "https://api.ctl.io/v2/servers/$AcctAlias/$ServerID/networks"
    $Result = Invoke-WebRequest -URI $RequestURL -Headers @{Authorization = $BearerToken} -Method POST -ContentType application/json -Body $NetworkInfo -Verbose

    LogWrite $Result | FL
