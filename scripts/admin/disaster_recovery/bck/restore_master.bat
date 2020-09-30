@echo on
rem ***********************************************************************************
rem *	restore_master.bat        ***Generic ***                                      *
rem *	                                                                              *
rem * 	Arguments:  %1	server name                                                   *
rem *		    %2	dump location.  e.g. e:\cies_restore\                         *
rem *		    %3	zip location                                                  *
rem *		    %4	zip file name                                                 *
rem *                                                                                 *
rem *	Description:	This script is run on weekends to archive dumps and load from *
rem *			other servers.  It is used toupdate a disaster recovery server*
rem *			at a remote location with the weeks data.                     *
rem *                                                                                 *
rem *	Date			By		Changes                               *
rem * 	01/08/2004	Aron E. Tekulsky	Initial creation.                     *
rem *	09/24/2008	Aron E. Tekulsky	modified version for SQL Server.      *
rem *	09/29/2008	Aron E. Tekulsky	add pass item for unzip.              *
rem *                                                                                 *
rem ***********************************************************************************

rem *set server=USCIPSYB01
set server=%1
set dump_location=%2
set zip_location=%3
rem ***set pb_unload=%4
set zip_file_name=%4

for /f "delims==" %%j IN ('date /T') DO set cday=%%j
for /f "delims==" %%j IN ('time /T') DO set ctime=%%j

echo beginning disaster recovery database load job at %cday% %ctime%

rem ***** Archive all logs *****
rem calculate datestamp in MS-DOS
::@echo off
for /f "tokens=2,3,4 delims=/ " %%a in ('date /t') do set zdate=%%c%%a%%b

rem the following line strips out the "19" in "1999"
rem set zdate=%zdate:~2%

for /f "tokens=1-10 delims=:. " %%a in ('echo.^| time ^| findstr "current"') do (
    set zhh=%%e
    set zmm=%%f
    set zss=%%g
)
if 10 GTR %zhh% set zhh=0%zhh%
set ztime=%zhh%.%zmm%.%zss%

call xcopy F:\scripts\admin\disaster_recovery\log\*.log F:\scripts\admin\disaster_recovery\log\archive\*.%zdate%%zhh%%zmm%%zss%
del F:\scripts\admin\disaster_recovery\log\*.log

rem *goto :powerbuilder

for /f "tokens=2,3,4 delims=/ " %%a in ('date /t') do set zdate=%%c%%a%%b
for /f "tokens=1-10 delims=:. " %%a in ('echo.^| time ^| findstr "current"') do (
    set zhh=%%e
    set zmm=%%f
    set zss=%%g

)
if 10 GTR %zhh% set zhh=0%zhh%
rem set ztime=%zhh%.%zmm%.%zss%
set ztime=%zhh%%zmm%%zss%

rem *c:
rem *cd sybase\scripts\admin\disaster_recovery

rem for /f "delims==" %%i IN ('if not defined src_database ^(type %jobname%.conf^) else ^(echo %src_database%^)') DO (
rem for /f "delims==" %%i IN ('if not defined src_database ^(type disast.conf^) else ^(echo %src_database%^)') DO (
rem *for /f "delims==" %%i IN (' ^(type disast.conf^) ') DO (
for /f "delims==" %%i IN (' ^(type F:\scripts\admin\disaster_recovery\config\disast.conf^) ') DO (
  rem
  rem Clean both trans and dump files of the source database
  rem --------------------------------------------------------------------------------------


rem insert row to show status of beginning unzip
for /f "delims==" %%j IN ('date /T') DO set cday=%%j
for /f "delims==" %%j IN ('time /T') DO set ctime=%%j

  echo beginning file unZip for database %%i at %cday% %ctime%
rem date /T
rem time /T

rem *set dump_location = "e:\cies_restore\dumps\"


for /f "tokens=1-10 delims=:. " %%a in ('echo.^| time ^| findstr "current"') do (
    set zhh=%%e
    set zmm=%%f
    set zss=%%g

)
if 10 GTR %zhh% set zhh=0%zhh%
set ztime=%zhh%%zmm%%zss%

rem goto loading

rem rename the old one to be in the archive directory
for /f "delims==" %%j IN ('date /T') DO set cday=%%j
for /f "delims==" %%j IN ('time /T') DO set ctime=%%j

echo Beginning archive of old dump for database %%i at %cday% %ctime%
call F:\scripts\admin\disaster_recovery\archive_dumps.bat %%i %zdate% %ztime% %server% %dump_location%> F:\scripts\admin\disaster_recovery\log\archive_dumps.log


for /f "delims==" %%j IN ('date /T') DO set cday=%%j
for /f "delims==" %%j IN ('time /T') DO set ctime=%%j

echo Ending archive of old dump for database %%i at %cday% %ctime%

for /f "delims==" %%j IN ('date /T') DO set cday=%%j
for /f "delims==" %%j IN ('time /T') DO set ctime=%%j

echo Beginning Deleting old dump for database %%i at %cday% %ctime%

rem *del e:\cies_restore\dumps\%%i.dmp /q /s
rem *****del %dump_location%\dumps\%%i.bak /q /s
del %dump_location%\dumps\*.bak /q /s

for /f "delims==" %%j IN ('date /T') DO set cday=%%j
for /f "delims==" %%j IN ('time /T') DO set ctime=%%j

echo Delete of old dump for database %%i completed at %cday% %ctime%

for /f "delims==" %%j IN ('date /T') DO set cday=%%j
for /f "delims==" %%j IN ('time /T') DO set ctime=%%j

echo Beginning Unzip of Dump for database %%i at %cday% %ctime%

rem *call wzunz.bat e:\cies_restore\%%i.zip  e:\cies_restore\dumps > unwz.%%i
rem *****call wzunz.bat %zip_location%\%%i.zip  %dump_location%\dumps > F:\scripts\admin\disaster_recovery\log\unwz.%%i
call F:\scripts\admin\disaster_recovery\wzunz.bat %zip_location%\%zip_file_name%.zip  iie_enterprise*.* %dump_location%\dumps > F:\scripts\admin\disaster_recovery\log\unwz.%%i


for /f "delims==" %%j IN ('date /T') DO set cday=%%j
for /f "delims==" %%j IN ('time /T') DO set ctime=%%j

echo Unzip of dump for database %%i completed at %cday% %ctime%

rem update status row to show unzip is complete

rem update status row to show load is beginning



for /f "delims==" %%j IN ('date /T') DO set cday=%%j
for /f "delims==" %%j IN ('time /T') DO set ctime=%%j
:loading
echo loading dump for database %%i on server %server% at %cday% %ctime%
rem date /T
rem time /T

rem call load_database %%i "e:\cies_restore\dumps" > load_database_%%i.log
rem call load_database.bat %%i  e:\cies_restore\dumps\  > load_database_%%i.log
call F:\scripts\admin\disaster_recovery\load_database %%i  %dump_location%\dumps %server% > F:\scripts\admin\disaster_recovery\log\load_database_%%i.log

for /f "delims==" %%j IN ('date /T') DO set cday=%%j
for /f "delims==" %%j IN ('time /T') DO set ctime=%%j

echo loading of dump for database %%i completed at %cday% %ctime%
rem date /T
rem time /T

rem update row to show load has completed

)

