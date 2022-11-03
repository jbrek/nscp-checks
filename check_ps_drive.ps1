#checking drive space 
#$stopwatch = [system.diagnostics.stopwatch]::StartNew()
#nagios stuff
$returnStateOK = 0
$returnStateWarning = 1
$returnStateCritical = 2
$returnStateUnknown = 3
$returnarray = @()
$exitcode = $returnStateUnknown


if ($args.count -eq 3)
    {
     $drive = $args[0]
     $nagioswarn = $args[1]
     $nagioscrit = $args[2]
    }
    else
    {
    #Write-host "Using default values"
    $drive = "C"
    $nagioswarn = 85
    $nagioscrit = 95
    }

$d = Get-PSDrive $drive 
$size = ($d.free + $d.used) 

$percent =  [math]::Round((100 - (($d.free / $size) * 100)))
$output = $drive + " is " + $percent + "% used. " + [math]::Round(($d.free/1GB),2) + "GB free of " +  [math]::Round(($size/1GB),2)+"GB"
$OutputPerfdata +=" | " + $drive + " used_%=" + $percent+";"+$nagioswarn+";"+$nagioscrit+";0;100 used_GB=" + [math]::Round((($size/1GB) - ($d.free/1GB)),2) +";"+ [math]::Round(($nagioswarn * 0.01) * ($size/1GB),2)+";"+[math]::Round(($nagioscrit * 0.01) * ($size/1GB),2) + ";0;" +[math]::Round(($size/1GB),2)

if($percent  -ge $nagioscrit )
        {
        $returnarray  = "CRITICAL: $output $OutputPerfdata" 
        $exitcode = $returnStateCritical
        }
    elseif ($percent  -ge $nagioswarn) 
        {
        $returnarray = "WARNING: $output $OutputPerfdata" 
        $exitcode = $returnStateWarning
        }
    else {
        $returnarray= "OK: $output $OutputPerfdata"
        $exitcode = $returnStateOK
        }



Write-host $returnarray
#write-host "total seconds" $stopwatch.Elapsed.totalseconds
#$stopwatch.stop()
exit $exitcode