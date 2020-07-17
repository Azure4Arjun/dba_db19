# Initialization
$Configurations = "L:\ViventiumEast\" <# set value to determine Destination location #>
$ServerInstance = "E-TEKNOLOGIES\SQL2019"
$SourcePath = "L:\SQLINSTALL_SQL2019\BACKUP01\"
$SourceFileType = "*.bak"
$SourceFileName = "test"
$FullSourcePath = $SourcePath + $SourceFileType
$DirListPath = "L:\SQLINSTALL_SQL2019\BACKUP01\"
$DirListFile = "dirlist.txt"
$FullDirListPath = $DirListPath + $DirListFile
$FullBackupFilePath = $SourcePath + "*.BAK"
$ZipDestinationFilePath = "L:\SQLINSTALL_SQL2019\BACKUP01\"
$ZipDestinationFile = $SourceFileName + ".zip"
$FullZipDestinationFilePath = $ZipDestinationFilePath + $ZipDestinationFile
$BeforeHash=""
$AfterHash = ""
#
#
#do the backups
Write-Host "1 Starting backups ON $($ServerInstance ) "
#
Get-SqlDatabase -ServerInstance $($ServerInstance ) | Where { $_.Name -ne 'tempdb' } | Backup-SqlDatabase
#
# Create a list of backup files
Write-Host "2 Creating list of backup files at $($FullSourcePath) "
#
Get-ChildItem -Path $($FullSourcePath) -Name > $($FullDirListPath)  <# puts dir info into file #>
#
# Read out the list
Write-Host " 3 Read out the list in the array  in $($FullDirListPath)"
#
Get-Content -Path $($FullDirListPath)  <# you can set up a variable such as $mytext = to be a holder of the data read in and its then an array #>
#
# Compress the bak files
Write-Host " 4 Compress the bak files located at $($SourcePath) AND FullBackupFilePath IS $($FullBackupFilePath) TO $FullZipDestinationFilePath"
#
#Compress-Archive -LiteralPath $($FullBackupFilePath) -DestinationPath $($FullZipDestinationFilePath) <# Compress the bak file  literal path does not accept wildcards#>
#
Compress-Archive -Path $($FullBackupFilePath) -DestinationPath $($FullZipDestinationFilePath) <# Compress the bak file #>
#
# get the fiule hash of the zip file.
Write-Host " 5 Get the file hash of the zip "
#
$BeforeHash = Get-FileHash "$($ZipDestinationFilePath)$($ZipDestinationFile)" -Algorithm MD5  <# creaate the file hash #>
#
#Write-Host "Before has is $($BeforeHash) "
Write-Host "Before has is $($BeforeHash.Hash) "
#
# Copy the file to a destination
Write-Host "6 Copy the file to Destination $($Configurations)"
#
#    { Copy-Item -Filter *.zip -Path L:\SQLINSTALL_SQL2019\BACKUP01  -Destination L:\ViventiumEast }

<#if ($Configurations -eq 'L:\ViventiumEast\') 
    { Copy-Item  -Path L:\SQLINSTALL_SQL2019\BACKUP01\*.zip  -Destination L:\ViventiumEast }
    ELSE {Copy-Item  -Path L:\SQLINSTALL_SQL2019\BACKUP01\*.zip  -Destination L:\ViventiumWest\} # not -recursive, not -Filter
    #>

Copy-Item  -Path "$($ZipDestinationFilePath)*.zip"  -Destination $($Configurations) 

#
# now copy the hash to destination too.
#
# get hash of file in destination location
#
Write-Host "7 Get the hash of the zip file in destination location."
#
$AfterHash =Get-FileHash "$($Configurations)*.zip" -Algorithm MD5  <# creaate the file hash #>
#
#Write-Host "After has is $($AfterHash) "
Write-Host " After has is $($AfterHash.Hash) "
#
# now compare hashes
Write-Host " 8 Compare hashes "
#
IF ($BeforeHash.Hash -eq $AfterHash.Hash) {
        Write-Host " success "
        Write-Host "zip destination is $($FullZipDestinationFilePath)  AND Zip destination file is $($ZipDestinationFile)"
        Rename-Item -Path "$($Configurations)$($ZipDestinationFile)" -NewName "$($Configurations)$($ZipDestinationFile).hash"}
ELSE {Write-Host " failure"}

#Get-FileHash L:\ViventiumEast\form0.zip -Algorithm MD5  <# creaate the file hash #>