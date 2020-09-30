@echo on
rem ***********************************************************************************
rem *	ss_unload.bat    ****Generic****                                              *
rem *	                                                                              *
rem * 	Arguments:  %1	application to get.       usp                                 *
rem *				%2	pb source code location	  c:\pbsrc                            *
rem *				%3	project top level         fulbright or powerbuilder           *
rem *                                                                                 *
rem *	Description:	This script is run on a scheduled basis to unload the         *
rem *                   application from source safe.                                 *
rem *	Date		By					Changes                                       *
rem *	07/23/2004	Aron E. Tekulsky   	Initial creation.                             *
rem *	07/29/2004	Aron E. Tekulsky	Add pb source code location argument.         *
rem *                                                                                 *
rem ***********************************************************************************

for /f "delims==" %%j IN ('date /T') DO set cday=%%j
for /f "delims==" %%j IN ('time /T') DO set ctime=%%j

echo Starting Unload of %1 PowerBuilder source code from VSS at %cday% %ctime%..


rem first delete previous source
rem *del c:\pbsrc\*.* /q/f
del %2\*.* /q/f

rem second get the source unloaded

rem *cd \pbsrc
cd %2

rem **ss cp $/PowerBuilder/%1/%1 
ss cp $/%3/%1


ss get *.* 

cd c:\sybase\scripts\admin\disaster_recovery

for /f "delims==" %%j IN ('date /T') DO set cday=%%j
for /f "delims==" %%j IN ('time /T') DO set ctime=%%j

echo Unload of PowerBuilder application %1 completed at %cday% %ctime%.
