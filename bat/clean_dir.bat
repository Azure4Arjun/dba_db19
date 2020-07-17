@echo off
rem ***********************************************************************************
rem *	clean_dir.bat                                                                 *
rem *	                                                                              *
rem * 	Arguments:  			                                              *
rem *				%2		                                      *
rem *                                                                                 *
rem *	Description:								      *
rem *										      *
rem *                                                                                 *
rem *	Date		Modified By			Changes                       *
rem *	08/21/2000	Dimitri Buzkoff    	Initial creation.                     *
rem * 	12/26/2001	Aron E. Tekulsky	Add header.                           *
rem *                                                                                 *
rem ***********************************************************************************
rem 
echo.
rem cd f:\fgrestore
FOR /F "delims==" %%i IN ('echo %0') DO set jobname=%%~ni
set history=6
echo Cleaning %1, keeping history of %history% days..	>> %1%\clean_dir.txt
echo List of files to be removed:			>> %1%\clean_dir.txt
f:\scripts\forfiles -d-%history% -P%1 -c"cmd /c echo @FILE"		>> %1%\clean_dir.txt
f:\scripts\forfiles -d-%history% -P%1 -c"cmd /c del @FILE"		>> %1%\clean_dir.txt
rem f:\scripts\forfiles -d-%history% -P%1 -c"cmd /c dir @FILE"		>> %1%\clean_dir.txt
echo Done.
rem pause						>> %1%\clean_dir.txt
goto :EOF



