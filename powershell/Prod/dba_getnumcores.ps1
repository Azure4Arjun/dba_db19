#http://blogs.msdn.com/b/sqlsakthi/p/maxdop-calculator-sqlserver.aspx

#Get-WmiObject -namespace "root\CIMV2" -class Win32_Processor -Property NumberOfCores | select NumberOfCores
set-executionpolicy unrestricted
