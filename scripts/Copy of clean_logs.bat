@echo off
rem ***********************************************************************************
rem *	clean_logs.bat        **** Generic ****                                       *
rem *	                                                                              *
rem * 	Arguments:  	%1	Directory name	-	                              *
rem *			%2	# of days of history.	                              *
rem *                                                                                 *
rem *	Description:	This script is run every Saturday night only.  It cleans up   *
rem *			the log directory.                                            *
rem *                                                                                 *
rem *	Date		Modified By			Changes                       *
rem *	08/21/2000	Dimitri Buzkoff    	Initial creation                      *
rem * 	12/26/2001	Aron E. Tekulsky	Add header.                           *
rem *                                                                                 *
rem ***********************************************************************************
rem 
echo.
FOR /F "delims==" %%i IN ('echo %0') DO set jobname=%%~ni
for /f "delims==" %%i IN ('date /T') DO set cday=%%i
for /f "delims==" %%i IN ('time /T') DO set ctime=%%i

echo Starting at %cday% %ctime%.. 

if (%1)==() goto NoDir
set history=6
if not (%2)==() set history=%2
echo Cleaning %1, keeping history of %history% days..
echo List of files to be removed:
forfiles -p%1 -d-%history% -c"cmd /c echo @FILE"
forfiles -p%1 -d-%history% -c"cmd /c del @FILE"
echo Done.
goto EOF

:NoDir
echo Syntax: %jobname% $dir [$history]
echo   where $dir     = directory to clean
echo         $history = number of days to keep
echo.
goto EOF

:EOF
for /f "delims==" %%i IN ('date /T') DO set cday=%%i
for /f "delims==" %%i IN ('time /T') DO set ctime=%%i

echo Ending at %cday% %ctime%.. 

