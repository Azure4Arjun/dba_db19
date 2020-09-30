<* Compress-Archive -LiteralPath L:\SQLINSTALL_SQL2019\BACKUP01\form0.bak -DestinationPath L:\SQLINSTALL_SQL2019\BACKUP01\form0.zip *> <* do the bacxkup of the db. *>
<* Get-FileHash L:\SQLINSTALL_SQL2019\BACKUP01\form0.zip -Algorithm MD5 *> <* creaate the file hash *>
<* Get-ChildItem -Path L:\SQLINSTALL_SQL2019\BACKUP01\ -Name > L:\SQLINSTALL_SQL2019\BACKUP01\dirlist.txt *> <* puts dir info into file *>
<* Get-Content -Path L:\SQLINSTALL_SQL2019\BACKUP01\dirlist.txt *> <* you can set up a variable such as $mytext = to be a holder of the data read in and its then an array *> *>
<* Copy-Item -Filter *.txt -Path c:\data -Recurse -Destination C:\temp\text *>
<* $a = 10 *> <* set value of variable $a *>
<* $b = 20 *> <* set value of variable $b *>
<* if ($a -gt $b ) { Write-Host "$A wins! "} ELSE { Write-Host "$B wins !!"} *> <* compare values and prbyuilding a failover cluster *>
for (($i=1); $I -lt 10; $I++) { Write-Host "testing loop" $i } <* for loop *>.\.dotnet
