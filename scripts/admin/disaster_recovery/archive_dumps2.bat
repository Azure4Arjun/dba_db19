@echo off
rem ***********************************************************************************
rem *	archive_dumps.bat        ***Generic ***                                       *
rem *	                                                                              *
rem * 	Arguments:  %1	database name                                                 *
rem *		    %2	date                                                          *
rem *		    %3	time                                                          *
rem *		    %4	server name                                                   *
rem *		    %5	File location.  e.g. e:\cies_restore                          *
rem *                                                                                 *
rem *	Description:	This script is run on weekends to archive dumps and load from *
rem *			other servers.  It is used toupdate a disaster recovery server*
rem *			at a remote location with the weeks data.                     *
rem *                                                                                 *
rem *	Date			By		Changes                               *
rem * 	01/08/2004	Aron E. Tekulsky	Initial creation.                     *
rem *                                                                                 *
rem ***********************************************************************************

set databasename=%1
set file_date=%2
set file_time=%3
set server=%4
set file_location=%5

for /f "delims==" %%j IN ('date /T') DO set cday=%%j
for /f "delims==" %%j IN ('time /T') DO set ctime=%%j

echo beginning archiving of previous dumps at %cday% %ctime%


rem c:
rem cd sybase\scripts\admin\disaster_recovery



rem *echo copying e:\cies_restore\dumps\%1.dmp e:\cies_restore\dumps\archive\%1.dmp%2%3
echo copying %file_location%\dumps\%databasename%.bak %file_location%\dumps\archive\%databasename%.bak%file_date%%file_time%
rem *copy e:\cies_restore\dumps\%1.dmp e:\cies_restore\dumps\archive\%1.%2%3 
copy %file_location%\dumps\%databasename%*.bak %file_location%\dumps\archive\%databasename%*.%file_date%%file_time%

rem *for /f "delims==" %%j IN ('date /T') DO set cday=%%j
for /f "delims==" %%j IN ('time /T') DO set ctime=%%j

echo Ending archiving of previous dumps at %cday% %ctime%

rem *for /f "delims==" %%j IN ('date /T') DO set cday=%%j
for /f "delims==" %%j IN ('time /T') DO set ctime=%%j

echo Beginning cleanup of previous archives at %cday% %ctime%

rem *call ..\clean_logs e:\cies_restore\dumps\archive 6
call F:\scripts\clean_dir %file_location%\dumps\archive 10

rem *for /f "delims==" %%j IN ('date /T') DO set cday=%%j
for /f "delims==" %%j IN ('time /T') DO set ctime=%%j

echo Completed cleanup of previous archives at %cday% %ctime%
