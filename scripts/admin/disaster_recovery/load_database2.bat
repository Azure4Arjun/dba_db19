@echo on
rem ***************************************************************************
rem *	load_database.bat     ****Generic**** disaster version                *
rem *			                     			              *
rem *	Arguments:	%1	Name of database to restore.                  *
rem *			%2	Location.                        	      *
rem *			%3	Destination server.                           *
rem *			%4	ful dump file name.                           *
rem *							                      *
rem *	Description:	This job begins the process to restore the user       *
rem *			databases.	                                      *
rem *							                      *
rem *	Date		Modified By		Changes	                      *
rem *  06/12/2002	Aron E. Tekulsky Initial Creation.   	              *
rem *  09/24/2008	Aron E. Tekulsky  modified to use SQL Serevr commands.*
rem *  09/29/2008	Aron E. Tekulsky  add full dump file name parameter.  *
rem *  11/17/2008	Aron E. Tekulsky  change to sqlcmld instead of isql.  *
rem *									      *
rem ***************************************************************************
rem
for /f "delims==" %%i IN ('echo %0') DO set jobname=%%~ni
for /f "delims==" %%i IN ('date /T') DO set cdate=%%i
for /f "delims==" %%i IN ('time /T') DO set ctime=%%i

 
set databasename=%1
set file_location=%2
set dest_server=%3
set dumpfile_location=%4

rem ******************************************
rem ** clean out the dynamkic sql directory **
rem ******************************************

rem *del load_database%1.sql /q
rem *del dynamic_sql\load_database%1.sql /q
rem ***del F:\scripts\admin\disaster_recovery\dynamic_sql\load_database%databasename%*.sql /q /s
del F:\scripts\admin\disaster_recovery\dynamic_sql\%jobname%%databasename%*.sql /q /s

rem ****************************
rem ** create the dynamic sql **
rem ****************************

echo Starting load of %databasename% Database at %cdate% %ctime%

rem *****echo restore database %databasename% from "%file_location%\%databasename%.bak"	>>F:\scripts\admin\disaster_recovery\dynamic_sql\%jobname%%1.sql

rem **echo restore database %databasename% from DiSK='%file_location%\%dumpfile_location% WITH replace'	>>F:\scripts\admin\disaster_recovery\dynamic_sql\%jobname%%1.sql


echo restore database %databasename% from DiSK='%file_location%\%dumpfile_location%' WITH REPLACE	>>F:\scripts\admin\disaster_recovery\dynamic_sql\%jobname%%1.sql
echo go										                        >>F:\scripts\admin\disaster_recovery\dynamic_sql\%jobname%%1.sql

rem *****echo online database %databasename%                                    		>>F:\scripts\admin\disaster_recovery\dynamic_sql\%jobname%%1.sql
rem *****echo go										>>F:\scripts\admin\disaster_recovery\dynamic_sql\%jobname%%1.sql

rem get the password for the database

rem **********************************
rem ** call isql to run the command **
rem **********************************

rem *cmd/c "c:\sybase\bin\isql.exe" -Usa -Puscipsybs4_92 -SUSCIPSYBS4 < %jobname%%1.sql
rem ***isql -E -S%dest_server% -iF:\scripts\admin\disaster_recovery\dynamic_sql\%jobname%%1.sql

\\localhost\sql_binn\sqlcmd -E -S%dest_server% -iF:\scripts\admin\disaster_recovery\dynamic_sql\%jobname%%1.sql


for /f "delims==" %%i IN ('date /T') DO set cdate=%%i
for /f "delims==" %%i IN ('time /T') DO set ctime=%%i
echo Ending load of database %1 at %cdate% %ctime%
:eof
