<# initialization #>
$Configurations = "L:\ViventiumEast\" <# set value to determine Destination location #>
$BackupSource = "L:\SQLINSTALL_SQL2019\BACKUP01" + "\"
$BackupDestination = ""
$Command = ''



<# do the backups #>

<# Get list of backup files #>
$Command = 
 Get-ChildItem -Path L:\SQLINSTALL_SQL2019\BACKUP01\ -Name > L:\SQLINSTALL_SQL2019\BACKUP01\dirlist.txt  <# puts dir info into file #>
 $MyBackups = Get-Content -Path L:\SQLINSTALL_SQL2019\BACKUP01\dirlist.txt  <# you can set up a variable such as $mytext = to be a holder of the data read in and its then an array #>

<# read in the file list from the array in a loop and process individual zip files #>

Compress-Archive -LiteralPath L:\SQLINSTALL_SQL2019\BACKUP01\form0.bak -DestinationPath L:\SQLINSTALL_SQL2019\BACKUP01\form0.zip <# Compress the bak file #>
<# end of loop #>

<# Get-FileHash L:\SQLINSTALL_SQL2019\BACKUP01\form0.zip -Algorithm MD5 #> <# creaate the file hash #>

<# Copy-Item -Filter *.txt -Path c:\data -Recurse -Destination C:\temp\text #>
<# $a = 10 #> <# set value of variable $a #>
<# $b = 20 #> <# set value of variable $b #>
<# if ($a -gt $b ) { Write-Host "$A wins! "} ELSE { Write-Host "$B wins !!"} #> <# compare values and prbyuilding a failover cluster #>
for (($i=1); $I -lt 10; $I++) { Write-Host "testing loop" $i } <# for loop #>

<# ForEach ($File in (Get-Content "L:\SQLINSTALL_SQL2019\BACKUP01\dirlist.txt") ) {Write-Host $File} #> <# read each item individually #>
# “$_.” defines current element in the pipe

<# $array8 = @("Earth","Mercury","Venus","Jupiter","Saturn","Mars", "Neptune", "Pluto")

 foreach ($array in $array8) {
   "$array = " + $array.length
 } #>  # looping through an array

