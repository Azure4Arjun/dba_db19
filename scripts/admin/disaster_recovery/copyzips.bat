@echo off
rem ***********************************************************************************
rem *	copyzips.bat         ****GENERIC****                                          *
rem *	                                                                              *
rem * 	Arguments:  %1	Copy destination.   \\10.10.10.157\admin_e                    *
rem *				%2	Name of zip file.   databasename                              *
rem *				%3	username.                                                     *
rem *				%4 	password.                                                     *
rem *				%5	zip file location.  d:\sybase2\zip                            *
rem *				%6	restore location.   restore                                   *
rem *                                                                                 *
rem *	Description:	This script is called by disast_mast to copy zip files to     *
rem *					another location.                                             *
rem *                                                                                 *
rem *	Date		By					Changes                                       *
rem *	01/08/2004	Aron E. Tekulsky   	Initial creation.                             *
rem *	04/28/2004	Aron E. Tekulsky	Add back /y flag.                             *
rem *	05/11/2004	Aron E. Tekulsky	remove user and pw from net use.              *
rem *                                                                                 *
rem ***********************************************************************************
rem Achtung! Transaction directory must be different than the main
rem directory for night dumps, since it gets cleaned up
for /f "delims==" %%i IN ('echo %0') DO set jobname=%%~ni
goto :Start

rem --------------------------------------------------------------
rem --------------------------------------------------------------

:Syntax
goto :EOF


:Start

for /f "delims==" %%i IN ('date /T') DO set cdate=%%i
for /f "delims==" %%i IN ('time /T') DO set ctime=%%i

if defined level (set /A level=level+1) else set level=0

set src_server=%COMPUTERNAME%
rem *****set src_server=SBSERVER2

rem ****set tran_mode=%1

set dest_server=%1
set zipfile_src=%2
set dest_user=%3
set dest_pw=%4
set zipfile_location=%5
set restore_location=%6


rem -- Setting up standby transaction directories on both servers --
rem -- Split drive and rest of the past to connect to the remote file system --
set drive=%tran_dir:~0,1%
set restdir=%tran_dir:~3%

echo Starting %jobname% job between source %src_server% and destination %dest_server%
echo at %cdate% %ctime%, transition folders: %tran_dir% from %tran_src_dir%
rem goto :Apply

:XCopy
@echo on
echo setting up device mapping
rem *NET USE u: \\192.168.1.13\admin_e sybase /user:rackspac-1f8789\sybase_sa
rem ***NET USE u: %dest_server% %dest_pw% /user:%dest_user%
NET USE u: %dest_server% 

echo Copying over to the destination server
time /T

rem *  xcopy e:\sybase\dumps\%1.zip u:\cies_restore /y
rem *** this is working **  xcopy %zipfile_location% %zipfile_src%.zip u:\cies_restore /y
rem   xcopy %zipfile_location%\%zipfile_src%.zip u:\%restore_location% /y
  xcopy %zipfile_location%\%zipfile_src%.zip u:\%restore_location% /y
date /T
time /T

NET USE u: /DELETE


:Apply



echo Job %jobname% completed normally at
date /T
time /T
echo.
goto :EOF

rem ---------------------------------------------------------------------
rem ---------------------------------------------------------------------



