@echo on
rem ***********************************************************************************
rem *	restore_master.bat        ***Generic ***                                      *
rem *	                                                                              *
rem * 	Arguments:  %1	server name                                                   *
rem *		    %2	dump location.  e.g. e:\cies_restore\                         *
rem *		    %3	zip location                                                  *
rem *		    %4	zip file name                                                 *
rem *		    %5	database name                                                 *
rem *                                                                                 *
rem *	Description:	This script is run on weekends to archive dumps and load from *
rem *			other servers.  It is used toupdate a disaster recovery server*
rem *			at a remote location with the weeks data.                     *
rem *                                                                                 *
rem *	Date			By		Changes                               *
rem * 	01/08/2004	Aron E. Tekulsky	Initial creation.                     *
rem *	09/24/2008	Aron E. Tekulsky	modified version for SQL Server.      *
rem *	09/29/2008	Aron E. Tekulsky	add pass item for unzip and load.     *
rem *                                                                                 *
rem ***********************************************************************************

set server=%1
set dump_location=%2
set zip_location=%3
set zip_file_name=%4
set databasename=%5

rem ***************************
rem ** get the date and time **
rem ***************************

for /f "delims==" %%j IN ('date /T') DO set cday=%%j
for /f "delims==" %%j IN ('time /T') DO set ctime=%%j

echo beginning disaster recovery database load job at %cday% %ctime%
rem **********************
rem ** Archive all logs **
rem **********************

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

rem ********************
rem ** delete old log **
rem ********************

del F:\scripts\admin\disaster_recovery\log\*.log /s


for /f "tokens=2,3,4 delims=/ " %%a in ('date /t') do set zdate=%%c%%a%%b
for /f "tokens=1-10 delims=:. " %%a in ('echo.^| time ^| findstr "current"') do (
    set zhh=%%e
    set zmm=%%f
    set zss=%%g

)

if 10 GTR %zhh% set zhh=0%zhh%
rem set ztime=%zhh%.%zmm%.%zss%
set ztime=%zhh%%zmm%%zss%

rem for /f "delims==" %%i IN ('if not defined src_database ^(type %jobname%.conf^) else ^(echo %src_database%^)') DO (
rem for /f "delims==" %%i IN ('if not defined src_database ^(type disast.conf^) else ^(echo %src_database%^)') DO (
rem *for /f "delims==" %%i IN (' ^(type disast.conf^) ') DO (
	
rem ****** 111708for /f "delims==" %%i IN (' ^(type F:\scripts\admin\disaster_recovery\config\disast.conf^) ') DO (

rem ************************************************************
rem ** this takes the place of the loop with the config file. **
rem ************************************************************

rem aet set %%i=%databasename%

  rem
  rem Clean both trans and dump files of the source database
  rem --------------------------------------------------------------------------------------


		rem insert row to show status of beginning unzip
	for /f "delims==" %%j IN ('date /T') DO set cday=%%j
	for /f "delims==" %%j IN ('time /T') DO set ctime=%%j

	  echo beginning file unZip for database %databasename% at %cday% %ctime%
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

	rem *******************************************************
	rem ** rename the old one to be in the archive directory **
	rem *******************************************************

	for /f "delims==" %%j IN ('date /T') DO set cday=%%j
	for /f "delims==" %%j IN ('time /T') DO set ctime=%%j

	echo Beginning archive of old dump for database %databasename% at %cday% %ctime%

	call F:\scripts\admin\disaster_recovery\archive_dumps2.bat %databasename% %zdate% %ztime% %server% %dump_location%> F:\scripts\admin\disaster_recovery\log\archive_dumps.log


	for /f "delims==" %%j IN ('date /T') DO set cday=%%j
	for /f "delims==" %%j IN ('time /T') DO set ctime=%%j

	echo Ending archive of old dump for database %databasename% at %cday% %ctime%

	for /f "delims==" %%j IN ('date /T') DO set cday=%%j
	for /f "delims==" %%j IN ('time /T') DO set ctime=%%j
	
	rem *****************************
	rem ** clear out dump location **
	rem *****************************

	echo Beginning Deleting old dump for database %databasename% at %cday% %ctime%

	del %dump_location%\dumps\*.bak /q /s

	for /f "delims==" %%j IN ('date /T') DO set cday=%%j
	for /f "delims==" %%j IN ('time /T') DO set ctime=%%j

	echo Delete of old dump for database %databasename% completed at %cday% %ctime%

	for /f "delims==" %%j IN ('date /T') DO set cday=%%j
	for /f "delims==" %%j IN ('time /T') DO set ctime=%%j

	rem *********************
	rem ** unzip new dumps **
	rem *********************

	echo Beginning Unzip of Dump for database %databasename% at %cday% %ctime%

	call F:\scripts\admin\disaster_recovery\wzunz2.bat %zip_location%\%zip_file_name%.zip  *.bak %dump_location%\dumps > F:\scripts\admin\disaster_recovery\log\unwz.%databasename%


	for /f "delims==" %%j IN ('date /T') DO set cday=%%j
	for /f "delims==" %%j IN ('time /T') DO set ctime=%%j

	echo Unzip of dump for database %databasename% completed at %cday% %ctime%

	rem update status row to show unzip is complete

	rem update status row to show load is beginning

	rem *** set up file with db name ***

rem *************************************************************
rem ** create dynamic config file with names of database dumps **
rem *************************************************************

	dir /B %dump_location%\dumps\*.bak > F:\scripts\admin\disaster_recovery\config\loadconfig.conf

	for /f "delims==" %%k IN (' ^(type F:\scripts\admin\disaster_recovery\config\loadconfig.conf^) ') DO (


		for /f "delims==" %%j IN ('date /T') DO set cday=%%j
		for /f "delims==" %%j IN ('time /T') DO set ctime=%%j
:loading
		echo loading dump for database %databasename% on server %server% at %cday% %ctime%
		rem date /T
		rem time /T

		rem ***********************
		rem ** Load the database **
		rem ***********************

		call F:\scripts\admin\disaster_recovery\load_database2 %databasename%  %dump_location%\dumps %server% %%k> F:\scripts\admin\disaster_recovery\log\load_database_%%k.log

		for /f "delims==" %%j IN ('date /T') DO set cday=%%j
		for /f "delims==" %%j IN ('time /T') DO set ctime=%%j

		rem ****echo loading of dump for database %databasename% completed at %cday% %ctime%
		echo loading of dump for database %%k completed at %cday% %ctime%
		rem date /T
		rem time /T

		rem update row to show load has completed
	)

rem ***** 111708)

