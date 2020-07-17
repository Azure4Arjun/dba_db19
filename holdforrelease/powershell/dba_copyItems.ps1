<* Compress-Archive -LiteralPath L:\SQLINSTALL_SQL2019\BACKUP01\form0.bak -DestinationPath L:\SQLINSTALL_SQL2019\BACKUP01\form0.zip *>
<* Get-FileHash L:\SQLINSTALL_SQL2019\BACKUP01\form0.zip -Algorithm MD5 *>
<* Get-ChildItem -Path L:\SQLINSTALL_SQL2019\BACKUP01\  > L:\SQLINSTALL_SQL2019\BACKUP01\dirlist.txt *>
<* Get-Content -Path L:\SQLINSTALL_SQL2019\BACKUP01\dirlist.txt <* you can set up a variable such as $mytext = to be a holder of the data read in and its then an array *> *>
Copy-Item -Filter *.txt -Path c:\data -Recurse -Destination C:\temp\text