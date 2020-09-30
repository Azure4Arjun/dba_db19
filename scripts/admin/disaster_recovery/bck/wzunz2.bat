echo on
rem ***********************************************************************************
rem *	wzunz2.bat                ****Generic****                                     *
rem *	                                                                              *
rem * 	Arguments:  %1	Dump file name and directory.   d:\sybase2\zip\iiedb1.zip     *
rem *		    %2	Zip file name and destination.  d:\sybase2\zip\iiedb1.dmp     *
rem *		    %3	Zip source directory.                                         *
rem *                                                                                 *
rem *	Description:	This script is run called by disast_master to zip up dump file*
rem *                                                                                 *
rem *	Date		By			Changes                               *
rem *	01/08/2004	Aron E. Tekulsky   Initial creation.                          *
rem *	05/04/2004	Aron E. Tekulsky   add code to allow for set up of device.    *
rem * 	11/17/2008	Aron E. Tekulsky   change to using localhost and winzip share.*
rem *                                                                                 *
rem ***********************************************************************************

for /f "delims==" %%j IN ('date /T') DO set cday=%%j
for /f "delims==" %%j IN ('time /T') DO set ctime=%%j

echo begin unzip of database %2 at %cday% %ctime%
rem e:
rem cd cies_restore\dumps
rem 1 zipfile, 2 imte, 3 destination

cmd/c "\\localhost\winzip\wzunzip.exe" %1 %2 %3
rem ***cmd/c "c:\program files\winzip\wzunzip.exe" %1 %2 %3
rem cmd/c "c:\program files\winzip\wzunzip.exe" -o %1

for /f "delims==" %%j IN ('date /T') DO set cday=%%j
for /f "delims==" %%j IN ('time /T') DO set ctime=%%j

echo Completed unzip of database %2 at %cday% %ctime%
