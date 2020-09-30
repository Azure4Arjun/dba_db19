@echo on
rem ***********************************************************************************
rem *	ss_unload.bat    ****Generic****                                              *
rem *	                                                                              *
rem * 	Arguments:  %1	application to get.                                           *
rem *                                                                                 *
rem *	Description:	This script is run on a scheduled basis to unload the         *
rem *                   application from source safe.                                 *
rem *	Date		By					Changes                                       *
rem *	07/23/2004	Aron E. Tekulsky   	Initial creation.                             *
rem *                                                                                 *
rem ***********************************************************************************

for /f "delims==" %%j IN ('date /T') DO set cday=%%j
for /f "delims==" %%j IN ('time /T') DO set ctime=%%j

echo Starting Unload of %1 PowerBuilder source code from VSS at %cday% %ctime%..


rem first delete previous source
del c:\pbsrc\*.* /q/f

rem second get the source unloaded

cd \pbsrc

ss cp $/PowerBuilder/%1/%1 

rem set working folder
ss workfold c:\pbsrc

ss get *.* 

for /f "delims==" %%j IN ('date /T') DO set cday=%%j
for /f "delims==" %%j IN ('time /T') DO set ctime=%%j

echo Unload of PowerBuilder application %1 completed at %cday% %ctime%.
