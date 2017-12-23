<#
.Synopsis
    Basic script that reads input file and write 2 logfiles. One full log and one summary log.
.DESCRIPTION
    Basic script that reads input file and write 2 logfiles. One full log and one summary log.
    - example with parameters and one mandatory input

.EXAMPLE  
    Example with all parameters
   .\Example.ps1 -WorkingDirectory "C:\TEMP" -logfile "Example_date.log" -summaryfile "Example_Summary_date.csv" -inputfile "input.csv"

.INPUTS
    Mandatory input file, default name is "input.csv", can be overridden with parameter -inputfile
    Create an input file named "input.csv" with the following content:

    Hostname,IP address,User
    mercurius,10.10.0.1,adminm
    venus,10.10.0.2,adminv
    earth,10.10.0.3,admine
    mars,10.10.0.4,adminm

.OUTPUTS
    Full log file, default name is "Example_date.log", can be overridden with parameter -logfile
    Summary file, default name is "Example_Summary_date.log", can be overridden with parameter -summaryfile 

.NOTES
    DISCLAIMER: This script is not supported under any support program or service.
    This script is provided AS IS without warranty of any kind.
    The author further disclaims all implied warranties including, without limitation, any implied warranties of merchantability or of fitness
    for a particular purpose.   

.COMPONENT

.ROLE

.FUNCTIONALITY
   Reads input file and writes output files, demonstration of the function logit

.VERSION
    20171218_1015

#>

Param (
        # The path to the folder for output files
        [string]$WorkingDirectory = ".",
        #file with extended logging
        [string]$logfile="",
        #output file with the summary
        [string]$summaryfile="",
        # The path to the input file
        [Parameter(Mandatory=$True,Position=1)]
        [string]$inputfile ="input.csv"
        # Final parameter ends without comma
)

#
# logit function to log output to the logfile AND screen
# 1st parameter = message written to logfile
# 2nd parameter = 1 - log to output and screen
# 2nd parameter, value other then 1 changes foreground color: 2=green, 3=blue, 4=red, 5=purple etc
function logit($message , $toscreen)
{
   Write-Output $message | Out-File -FilePath $logfile -Encoding "utf8"  -Append   #avoid UTF-16 output
   IF(-NOT [string]::IsNullOrWhiteSpace($toscreen)) 
   {
      if($toscreen -eq "1")
      { Write-Host $message}
      else
      { Write-Host -ForegroundColor $toscreen  $message}
   }
}

#
# Loop through input file and process it.
#           
function loop_through_all_hosts()
{
    $RowArray = @()
    foreach ($s in $ListofServers)
    {
        $Hostname = $s.Hostname
        $IP       = $s.IP
        $User     = $s.User
        # log to screen en log file
        # logit "Hostname: $Hostname , IP: $IP , User: $User" 1
        # Create summary file
        $row = "" | Select Out_Hostname, Out_IP, Out_Admin
        $row.Out_Hostname = $Hostname
        $row.Out_IP       = $IP
        $row.Out_Admin    = $User
 
        logit "$row" 2
        # Add to array
        $RowArray += $row
    }
    # Create export file
    if ($RowArray)
    {
        $RowArray | ft -autosize
        $RowArray | Export-Csv $summaryfile -useculture -notypeinformation
    }
}
 
#
#
#
#
#  MAIN starts here
#
# var for the project name
$project = "Example"
$currentLocation = Get-Location
$today = date -Format yyyyMMdd_hhmm
if($logfile -eq "") {$logfile="${WorkingDirectory}\${project}_${today}.log";}
Write-Host "Logfile: $logfile"
Write-Output "$project script version: 1.0 " | Out-File -FilePath $logfile -Encoding "utf8"
logit "Date: $today"
if($summaryfile -eq "") {${summaryfile}="${WorkingDirectory}\${project}_Summary_${today}.csv";}
logit "Summaryfile: $summaryfile" 1
# ----------------------------
# Check input file
if ( -not $inputfile)
{
    Write-Host -ForegroundColor Red "No file specified in -inputfile ."
    return
}
if ( -not (Test-path $inputfile) )
{
    Write-Host -ForegroundColor Red "File $inputfile does not exist."
    return
}
# ----------------------------
# Process the input file
logit "Reading CSV input file $inputfile" 1
$i=0;
$ListofServers=@()
foreach($line in Get-Content $inputfile)
{
   if($i -eq 0 -AND $line -match "^Hostname,") {continue}  #headline starts with "Hostnanme" and must not be used
   if($line -notmatch "^\s*#"  )
   {
        $X=$line.Split(",")
        # input file must have 3 fields  
        if($X.Count -lt 3)
        {
            Write-Host -ForegroundColor Red "Bad format found in CSV file - please use Syntax: Hostname,IP address,User"
        }
        $ListofServers += @{Hostname=$X[0] ; IP=$X[1] ; User=$X[2]}
    }
    $i++
}
logit "There are $($ListofServers.Hostname.Count) Hosts in file $inputfile" 1
logit "To get the first hostname: $($ListofServers.Hostname[0]) " 1
logit "To get the third IP      : $($ListofServers.IP[2]) " 1
logit "##########################################################" 1
logit "############## Now start the loop ########################" 7
loop_through_all_hosts
logit "##########################################################" 1
logit "##################### End ################################" 1
logit "##########################################################" 1
#eof
