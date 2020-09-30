@echo off
rem ***********************************************************************************
rem *	clean_dir.bat                                                                 *
rem *	                                                                              *
rem * 	Arguments:  			                                              *
rem *			%1    	Path                                                  *
rem *			%2	# days                                                *
rem *                                                                                 *
rem *	Description:								      *
rem *										      *
rem *                                                                                 *
rem *	Date		Modified By			Changes                       *
rem *	08/21/2000	Dimitri Buzkoff    	Initial creation.                     *
rem * 	12/26/2001	Aron E. Tekulsky	Add header.                           *
rem *	05/30/2008	Aron E. Tekulsky	added passed days		      *
rem *                                                                                 *
rem ***********************************************************************************
rem 
rem echo.
rem cd f:\fgrestore
FOR /F "delims==" %%i IN ('echo %0') DO set jobname=%%~ni
--set history=6
set history=%2

echo Cleaning %1, keeping history of %history% days..	

rem ***>> f:\scripts\log\clean_dir.txt

echo List of files to be removed:
			
rem ***>> f:\scripts\log\clean_dir.txt

rem *** echo Cleaning %1, keeping history of %history% days..	>> %1%\clean_dir.txt
rem *** echo List of files to be removed:			>> %1%\clean_dir.txt
forfiles -d-%history% -P%1 -c"cmd /c echo @FILE"
rem ***	>> f:\scripts\log\clean_dir.txt
forfiles -d-%history% -P%1 -c"cmd /c del @FILE"	
rem ***	>> f:\scripts\log\clean_dir.txt
rem
rem ***f:\scripts\log\forfiles -d-%history% -P%1 -c"cmd /c echo @FILE"		>> %1%\clean_dir.txt
rem ***f:\scripts\log\forfiles -d-%history% -P%1 -c"cmd /c del @FILE"		>> %1%\clean_dir.txt
rem f:\scripts\log\forfiles -d-%history% -P%1 -c"cmd /c dir @FILE"		>> %1%\clean_dir.txt
echo Done.
rem pause						>> %1%\clean_dir.txt
goto :EOF



