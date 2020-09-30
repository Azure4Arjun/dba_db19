echo off

for /f "delims==" %%j IN ('date /T') DO set cday=%%j
for /f "delims==" %%j IN ('time /T') DO set ctime=%%j

echo begin unzip of database %2 at %cday% %ctime%
rem e:
rem cd cies_restore\dumps
rem 1 zipfile, 2 imte, 3 destination

cmd/c "c:\program files\winzip\wzunzip.exe" %1 %2 %3
rem cmd/c "c:\program files\winzip\wzunzip.exe" -o %1

for /f "delims==" %%j IN ('date /T') DO set cday=%%j
for /f "delims==" %%j IN ('time /T') DO set ctime=%%j

echo Completed unzip of database %2 at %cday% %ctime%
