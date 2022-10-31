#check_firewall
$nagioswarn = 1
$nagioscrit = 2
$returnStateOK = 0
$returnStateWarning = 1
$returnStateCritical = 2
$returnStateUnknown = 3
$exitcode = $returnStateUnknown 
$returnarray = @()

$results = netsh advfirewall show currentprofile
#$results | Select-String -Pattern  "Domain Profile" -CaseSensitive -SimpleMatch


if($results -like "Domain Profile*" )
{
    $returnarray="Domain Profile"
}
elseif($results -like "Private Profile*" )
{
     $returnarray="Private Profile"
}
elseif($results -like "Public Profile*" )
{
    #Write-host "Public Profile Active"
    $returnarray="Public Profile" 
}

if($results -like "State                                 ON")
    {
   $exitcode = $returnStateOK
   $returnarray  = "OK: Firewall ON $returnarray"
}
else
    {
    $exitcode = $returnStateCritical 
    $returnarray ="ERROR: Firewall OFF $returnarray"
    }



if($exitcode -eq "3"){
$returnarray = "Unknow Error"
}

$OutputPerfdata +=" | exitcode=$exitcode;$nagioswarn;$nagioscrit" 
Write-host $returnarray $OutputPerfdata
exit $exitcode
