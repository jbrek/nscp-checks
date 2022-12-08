'Check_NRPE Plugin to check disk space
'drive=d warn=90 crit=95 
'Example from powershell terminal line:  cscript .\check_drive.vbs -a D 90 95 
'Example for windows.cfg:  check_command       check_nrpe!check_drive -a "D 85 95"
'Example for nsclient.ini: check_drive = check_drive.vbs $ARG1$ $ARG2$ $ARG3$
'The nsclient wrapper.vbs takes Wscript.Arguments.Item(0)
'2022-12-7
strScriptHost = LCase(Wscript.FullName)

If Right(strScriptHost, 11) = "wscript.exe" Then
    Wscript.Echo "This script is running under WScript, Please run using cscript"
Wscript.quit
End If


'If WScript.Arguments.Count = 3 Then
strdrivearg = Wscript.Arguments.Item(1) 
strwarn = Wscript.Arguments.Item(2) 
strcrit = Wscript.Arguments.Item(3)
strdrive = Chr(39)&strdrivearg&chr(58)&Chr(39) 
'Else
'    strdrive = "'c:'"
'    strwarn = "85"
'    strcrit =  "95"
'End If
strexit = 3

strcomputer = "."
strquery = "SELECT * FROM Win32_LogicalDisk Where DeviceID ="

Set objWMIService = GetObject("winmgmts:\\" & strComputer & "\root\CIMV2")
 Set colItems = objWMIService.ExecQuery(strquery & strdrive , "WQL", _
 wbemFlagReturnImmediately + wbemFlagForwardOnly)
                                          
For Each objItem In colItems  
strsize =  Round((objItem.Size  / "1073741824"),0)
strfree = Round((objItem.FreeSpace / "1073741824"),0)
strpercent =  Round((100 - ((objItem.FreeSpace / objItem.Size) * 100)))

Next
stroutput = strdrivearg & " is " &strpercent& "% used. "& strfree &"GB free of " &strsize&"GB"
strperfoutput = " | " & strdrivearg & "_used_%=" & strpercent&"%;"&strwarn&";"&strcrit&";0;100 " & strdrivearg & "_used_GB=" & (strsize-strfree) &"GB;"&((strwarn * 0.01)* strsize)&";"&((strcrit* 0.01)* strsize)&";0;"&strsize

If(CInt(strpercent) >= CInt(strcrit))  Then
    wscript.echo "CRITICAL: "  & stroutput & strperfoutput
    strexit =2
    
ElseIf (CInt(strpercent) >= CInt(strwarn)) Then
    wscript.echo "WARNING: "   & stroutput & strperfoutput
    strexit = 1
Else
    wscript.echo "OK: " & stroutput  & strperfoutput
    strexit  = 0
End If 

Wscript.Quit(strexit)
'EndTime = Timer()
'Wscript.Echo "Seconds to 2 decimal places: " & FormatNumber(EndTime - StartTime, 4) 