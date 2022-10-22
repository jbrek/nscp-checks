#check_firewall

$returnStateOK = 0
$returnStateWarning = 1
$returnStateCritical = 2
$returnStateUnknown = 3

$returnarray = @()

$results = netsh advfirewall show currentprofile
#$results | Select-String -Pattern  "Domain Profile" -CaseSensitive -SimpleMatch

if($results -like "Domain Profile*" )
{
    #Write-host "Domain Profile Active"
    $returnarray="Domain Profile"
}
elseif($results -like "Private Profile*" )
{
    #Write-host "Private Profile Active"
    $returnarray="Private Profile"
}
elseif($results -like "Public Profile*" )
{
    #Write-host "Public Profile Active"
    $returnarray="Public Profile" 
}

if($results -like "State                                 ON")
    {
    write-host "OK: Firewall ON - $returnarray "
    $exitcode = $returnStateOK
    }
else
    {
    Write-host "ERROR: Firewall OFF - $returnarray"
    $exitcode = $returnStateCritical
    }
exit $exitcode
