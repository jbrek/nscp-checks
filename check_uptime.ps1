#nagioscrit set to 0 days, so after reboot will get alert
#nagioswarn set to 365 days, after 365 days  up will get alert

function Format-TimeSpan {
    process {
      "{0:00} Days {1:00} Hours {2:00} Minutes" -f $_.Days,$_.Hours,$_.Minutes
    }
  }

$nagioswarn = $args[0]
$nagioscrit = $args[1]
$returnStateOK = 0
$returnStateWarning = 1
$returnStateCritical = 2
$returnStateUnknown = 3
$returnarray = @()
$exitcode = $returnStateUnknown


$output = (get-uptime | Format-TimeSpan); 
$outputperfdata =" | " + "days_up=" + [math]::Round(((get-uptime).totaldays),2) +";31;365"

if((get-uptime).totalhours  -le $nagioscrit )
        {
        $returnarray  = "CRITICAL: $output $OutputPerfdata" 
        $exitcode = $returnStateCritical
        }
    elseif ((get-uptime).TotalDays -ge $nagioswarn) 
        {
        $returnarray = "WARNING: $output $OutputPerfdata" 
        $exitcode = $returnStateWarning
        }
    else {
        $returnarray= "OK: $output $OutputPerfdata"
        $exitcode = $returnStateOK
        }

Write-host $returnarray
exit $exitcode