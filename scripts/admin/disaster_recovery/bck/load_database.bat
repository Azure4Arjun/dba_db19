@echo on
rem ***************************************************************************
rem *	load_database.bat     ****Generic**** disaster version                *
rem *			                     			              *
rem *	Arguments:	%1	Name of database to restore.                  *
rem *			%2	Location.                        	      *
rem *			%3	Destination server.                           *
rem *							                      *
rem *	Description:	This job begins the process to restore the user       *
rem *			databases.	                                      *
rem *							                      *
rem *	Date		Modified By		Changes	                      *
rem *  06/12/2002	Aron. E. Tekulsky Initial Creation.   	              *
rem *  09/24/2008	Aron E. Tekulsky  modified to use SQL Serevr commands.*
rem *									      *
rem ***************************************************************************
rem
for /f "delims==" %%i IN ('echo %0') DO set jobname=%%~ni
for /f "delims==" %%i IN ('date /T') DO set cdate=%%i
for /f "delims==" %%i IN ('time /T') DO set ctime=%%i

 
set databasename=%1
set file_location=%2
set dest_server=%3

rem *del load_database%1.sql /q
rem *del dynamic_sql\load_database%1.sql /q
del F:\scripts\admin\disaster_recovery\dynamic_sql\load_database%databasename%.sql /q

rem *c:
rem *cd \sybase\scripts\admin\disaster_recovery

rem *echo Starting load of %1 Database at %cdate% %ctime%
echo Starting load of %databasename% Database at %cdate% %ctime%

rem echo load database %1 from "%2%1.dmp"		>>dynamic_sql\%jobname%%1.sql
rem *echo load database %1 from "%2%1.dmp"		>>dynamic_sql\%jobname%%1.sql
rem ***echo load database %databasename% from "%file_location%\%databasename%.dmp"	>>dynamic_sql\%jobname%%1.sql
rem *****echo restore database %databasename% from "%file_location%\%databasename%.bak"	>>F:\scripts\admin\disaster_recovery\dynamic_sql\%jobname%%1.sql
echo restore database %databasename% from DiSK='%file_location%\%databasename%.bak'	>>F:\scripts\admin\disaster_recovery\dynamic_sql\%jobname%%1.sql
echo go										>>F:\scripts\admin\disaster_recovery\dynamic_sql\%jobname%%1.sql
echo online database %databasename%                                    		>>F:\scripts\admin\disaster_recovery\dynamic_sql\%jobname%%1.sql
echo go										>>F:\scripts\admin\disaster_recovery\dynamic_sql\%jobname%%1.sql

rem get the password for the database
rem ***
rem call isql to run the command
rem ***isql -Ubackup_sa -P%sapwd% -S%dest_server% -idynamic_sql\%jobname%%1.sql
rem *cmd/c "c:\sybase\bin\isql.exe" -Usa -Puscipsybs4_92 -SUSCIPSYBS4 < %jobname%%1.sql
isql -E -S%dest_server% -iF:\scripts\admin\disaster_recovery\dynamic_sql\%jobname%%1.sql


for /f "delims==" %%i IN ('date /T') DO set cdate=%%i
for /f "delims==" %%i IN ('time /T') DO set ctime=%%i
echo Ending load of database %1 at %cdate% %ctime%
:eof
