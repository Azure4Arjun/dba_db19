# Initialization
$Configurations = "L:\ViventiumEast\" <# set value to determine Destination location #>
$ServerInstance = "E-TEKNOLOGIES\SQL2019"
$SourcePath = "L:\SQLINSTALL_SQL2019\BACKUP01\"
$DirListPath = "L:\mydirlists\"
$ZipDestinationFilePath = "L:\myzips\"
$ConfigMaxErrors=3
#
$SourceFileName = $File
$FullSourcePath = $SourcePath + $SourceFileName
$DirListFile = "dirlist.txt"
$FullDirListPath = $DirListPath + $DirListFile
$FullBackupFilePath = $SourcePath
$ZipDestinationFile = $SourceFileName + ".zip"
$FullZipDestinationFilePath = $ZipDestinationFilePath + $ZipDestinationFile
$BeforeHash=""
$AfterHash = ""
$CurrentFile = ""
$CurrentZipFileName = ""
$NewZipFileName =""
#
# Get-executionpolicy
#
# Set-ExecutionPolicy UnRestricted or remotesigned

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
#
# Now change to looping through them
Write-Host "3 Now we will begin to loop through them "
#
ForEach ($File in (Get-Content -Path $($FullDirListPath)) ) <# read each item individually #>
    {
    # adjust to new names for each loop run.
    $CurrentFile = "$($FullBackupFilePath)$($File)"
    $CurrentZipFileName = "$($ZipDestinationFilePath)$($File).zip"
    Write-Host " current file is $( $CurrentFile) "
    Write-Host " current zip file  name $($CurrentZipFileName) "
#
#
# Compress the bak files
    Write-Host " 4 Compress the bak files located at $($CurrentFile) AND FullBackupFilePath IS $($FullBackupFilePath)$($File) TO $($CurrentZipFileName)"
#
    Compress-Archive -Path $($CurrentFile) -DestinationPath $($CurrentZipFileName) <# Compress the bak file #>
#
# get the fiule hash of the zip file.
    Write-Host " 5 Get the file hash of the zip $($CurrentZipFileName)"
#
    $BeforeHash = Get-FileHash "$( $CurrentZipFileName)" -Algorithm MD5  <# creaate the file hash #>
#
    Write-Host "Before has is $($BeforeHash.Hash) "
#
# Copy the file to a destination
    Write-Host "6 Copy the file $($CurrentZipFileName) to Destination $($Configurations)"
#
    Copy-Item  -Path "$($CurrentZipFileName)"  -Destination $($Configurations) 
#
    $NewZipFileName = "$($Configurations)$($File).zip"
    Write-Host "6.5 new zip file name is $($NewZipFileName)"
#
# now copy the hash to destination too.
#
# get hash of file in destination location
#
    Write-Host "7 Get the hash of the zip file in destination location."
#
    $AfterHash =Get-FileHash "$( $NewZipFileName)" -Algorithm MD5  <# creaate the file hash #>
#
    Write-Host " After has is $($AfterHash.Hash) "
#
# now compare hashes
    Write-Host " 8 Compare hashes "
#
    IF ($BeforeHash.Hash -eq $AfterHash.Hash) {
            Write-Host " success "
            Write-Host "zip name was $($CurrentZipFileName)  AND Zip destination file is $($NewZipFileName).hash"
            Rename-Item -Path "$($NewZipFileName)" -NewName "$($NewZipFileName).hash"}
    ELSE {Write-Host " failure"}

      } #> <# read each item individually #>