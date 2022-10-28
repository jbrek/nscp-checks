#nagios check for cpu temerature
#"Example: .\get-cpu-temp.ps1 5 1 50 70
#"Example: .\get-cpu-temp.ps1 seconds polling nagioswarm nagioscritital
#Must use all args or will get defaut vaules
#"collect data for ~360 seconds, polling 1 second .\get-cpu-temp.ps1 360 1 50 70"
#"default is ~5 seconds"
#"default polling is  .5 second"

#Credit is due to links in comments
#For Hashtable example, used it.  

#Download https://github.com/LibreHardwareMonitor/LibreHardwareMonitor 
#copy LibreHardwareMonitorLib.dll to script DIR


function get-tempcpu{
    $ErrorActionPreference = 'SilentlyContinue'
    #https://www.reddit.com/r/PowerShell/comments/pjvoxm/get_cpu_temperature_wo_wmi/
    Add-Type -Path "C:\Program Files\NSClient++\scripts\LibreHardwareMonitorLib.dll"
    $computer = New-Object LibreHardwareMonitor.Hardware.Computer
    $computer.IsCpuEnabled = $TRUE
    #add catch error
    $computer.Open() 
        foreach ($hardware in $computer.Hardware)
        {  
            foreach ($sensor in $hardware.Sensors)
            { 
                if($sensor.Name -eq "Core Average")
                    {
                    #Write-host $sensor.Name $sensor.Value
                    $tempHastTable.add($stopwatch.Elapsed.totalseconds,$sensor.Value)
                   }   
            }        
        }
    }
    
    #nagios stuff
    $returnStateOK = 0
    $returnStateWarning = 1
    $returnStateCritical = 2
    $returnStateUnknown = 3
    $returnarray = @()
    $exitcode = $returnStateUnknown
    
    
    
    $stopwatch = [system.diagnostics.stopwatch]::StartNew()
    $filename=(Get-date).tostring("MMddyyyy-HHmmss")
    #$computer.IsGPUEnabled = $TRUE
    $scriptpath = Split-Path -parent $MyInvocation.MyCommand.Definition
    $tempHastTable = [ordered]@{}
    #$tempHastTable.add($key,$value)
    #start-sleep -second 2
    
    if ($args.count -eq 4)
    {
     $timer = $args[0]
     $poller = $args[1]
     $nagioswarn = $args[2]
     $nagioscrit = $args[3]
    }
    else
    {
    #write-host "Example collect data for ~360 seconds, polling 1 second .\get-cpu-temp.ps1 360 1"
    #Write-host "default is ~5 seconds"
    #Write-host "default polling is  .5 second"
    $poller = .5
    $timer = 5
    $nagioswarn = 55
    $nagioscrit = 65
    }
    Do
    {
    #calling function     
    get-tempcpu  
    start-sleep $poller
    #write-host $stopwatch.Elapsed.totalseconds
    }While([math]::Round($stopwatch.Elapsed.totalseconds) -le $timer )
    
    #nagios data
    # echo hashtable  secondds , C
    #$tempHastTable.GetEnumerator() | ForEach-Object{
    #    $message = '{0} , {1}' -f $_.key, $_.value
    #    Write-Output $message
    #}
    
    $cputempavg = $tempHastTable.values | Measure-Object -Average
    $cputempavg = [math]::round($cputempavg.Average,2)
    $OutputPerfdata +=" | CPU_Temperature_Celsius=$cputempavg;$nagioswarn;$nagioscrit"
    
    if($cputempavg -gt $nagioscrit )
        {
        $returnarray  = "CRITICAL: $cputempavg $OutputPerfdata" 
        $exitcode = $returnStateCritical
        }
    elseif ($cputempavg -gt $nagioswarn) 
        {
        $returnarray = "WARNING: $cputempavg $OutputPerfdata" 
        $exitcode = $returnStateWarning
        }
    else {
        $returnarray= "OK: $cputempavg $OutputPerfdata"
        $exitcode = $returnStateOK
        }
    
    $stopwatch.stop()
    Write-host $returnarray
    exit $exitcode
    #$computer.close()