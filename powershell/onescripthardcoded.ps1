# Initialization
$Configurations = "L:\ViventiumEast\" <# set value to determine Destination location #>
#
#do the backups
Write-Host "1 Starting backups"
#
Get-SqlDatabase -ServerInstance E-TEKNOLOGIES\SQL2019 | Where { $_.Name -ne 'tempdb' } | Backup-SqlDatabase
#
# Create a list of backup files
Write_Host "2 Createing list of backup files"
#
Get-ChildItem -Path L:\SQLINSTALL_SQL2019\BACKUP01\ -Name > L:\SQLINSTALL_SQL2019\BACKUP01\dirlist.txt  <# puts dir info into file #>
#
# Read out the list
Write_Host " 3 Read out the list in the array "
#
Get-Content -Path L:\SQLINSTALL_SQL2019\BACKUP01\dirlist.txt  <# you can set up a variable such as $mytext = to be a holder of the data read in and its then an array #>
#
# Compress the bak files
Write-Host " 4 Compress the bak fles"
#
Compress-Archive -LiteralPath L:\SQLINSTALL_SQL2019\BACKUP01\form0.bak -DestinationPath L:\SQLINSTALL_SQL2019\BACKUP01\form0.zip <# Compress the bak file #>
#
# get the fiule hash of the zip file.
Write-Host " 5 Get the file hash of the zip"
#
Get-FileHash L:\SQLINSTALL_SQL2019\BACKUP01\form0.zip -Algorithm MD5  <# creaate the file hash #>
#
# Copy the file to a destination
Write-Host "6 Copy the file to Destination $($Configurations)"
#
if ($Configurations -eq 'L:\ViventiumEast\') 
    { Copy-Item -Filter form0.bak -Path L:\SQLINSTALL_SQL2019\BACKUP01 -Recurse -Destination L:\ViventiumEast\ }
    ELSE {Copy-Item -Filter form0.bak -Path L:\SQLINSTALL_SQL2019\BACKUP01 -Recurse -Destination L:\ViventiumWest\}
#
# now copy the hash to destination too.
#
# get hash of file in destination location
#
Write-Host "7 Get the hash of the zip file in destination location."
#
#
# now compare hashes
Write-Host " 8 Compare hashes "
#
Write-Host" success or failure"

Get-FileHash L:\ViventiumEast\form0.zip -Algorithm MD5  <# creaate the file hash #>