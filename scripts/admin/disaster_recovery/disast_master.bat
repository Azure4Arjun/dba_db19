@echo on
rem ***********************************************************************************
rem *	disast_master.bat    ****Generic****                                          *
rem *	                                                                              *
rem * 	Arguments:  %1	Dump source directory.    d:\sybase2\dumps                    *
rem *		    %2	Copy destination.         \\10.10.10.157\admin_e              *
rem *		    %3	Zip source directory.     d:\sybase2\zip                      *
rem *		    %4	restore location.         restore                             *
rem *		    %5	pb executable location	  \\usnypflpt1\shared\Common\PBApps   *
rem *		    %6	pb source code location	  \\usnyp1sdb01\pbsrc                 *
rem *		    %7	project top level	fulbright or powerbuilder             *
rem *                                                                                 *
rem *	Description:	This script is run on a scheduled basis to create a zp file of*
rem *			database dumps and copy them to a destination server.         *
rem *                                                                                 *
rem *	  Date		    By				Changes                       *
rem *	01/08/2004	Aron E. Tekulsky   	Initial creation.                     *
rem *	07/14/2004	Aron E. Tekulsky	add routine to copy pb src files.     *
rem *	07/23/2004	Aron E. Tekulsky	Add routine to unload source from VSS.*
rem *                                                                                 *
rem ***********************************************************************************

for /f "delims==" %%j IN ('date /T') DO set cday=%%j
for /f "delims==" %%j IN ('time /T') DO set ctime=%%j

echo Starting disaster recovery copy at %cday% %ctime%..


set dump_src=%1
set copy_dest=%2
set zip_src=%3
set pb_exe=%5
set pb_src=%6

rem testing
rem ***goto :pbsrc
rem end testing

for /f "delims==" %%i IN (' ^(type config\disast.conf^) ') DO (
  rem
  rem Clean both trans and dump files of the source database
  rem --------------------------------------------------------------------------------------


for /f "delims==" %%j IN ('date /T') DO set cday=%%j
for /f "delims==" %%j IN ('time /T') DO set ctime=%%j

rem insert row to show status of beginning zip
  echo beginning file Zip up for database %%i at %cday% %ctime%


rem *call wz.bat e:\sybase\dumps\%%i.zip e:\sybase\dumps\%%i.dmp > wz.%%i
rem **** temp to test copy only **** call wz.bat %3\%%i.zip %1\%%i.dmp  > wz.%%i
call wz.bat %zip_src%\%%i.zip %dump_src%\%%i.dmp  > log\wz.%%i

for /f "delims==" %%j IN ('date /T') DO set cday=%%j
for /f "delims==" %%j IN ('time /T') DO set ctime=%%j

echo File zip for database %%i completed at %cday% %ctime%

rem update status row to show copy is beginning

rem now do copy to remote server

for /f "delims==" %%j IN ('date /T') DO set cday=%%j
for /f "delims==" %%j IN ('time /T') DO set ctime=%%j

echo Begin copying zip files for database %%i to remote server at %cday% %ctime%

rem *call copyzips %2 %%i rackspac-1f8789\sybase_sa sybase %3 %4 > log\copyzips_%%i.log
call copyzips %2 %%i sybase_sa sybase %3 %4 > log\copyzips_%%i.log
							
echo File copy for database %%i completed at %cday% %ctime%

rem update row to show copy is completed

)

:pbexe
rem *** now zip and copy all pb apps
for /f "delims==" %%j IN ('date /T') DO set cday=%%j
for /f "delims==" %%j IN ('time /T') DO set ctime=%%j

echo Begin ziping up PowerBuilder Application files at %cday% %ctime%
for /f "delims==" %%i IN (' ^(type config\disast_pb.conf^) ') DO (
call wz.bat %zip_src%\%%i.zip %pb_exe%\%%i\*.* > log\wz.%%i

rem now do copy to remote server

for /f "delims==" %%j IN ('date /T') DO set cday=%%j
for /f "delims==" %%j IN ('time /T') DO set ctime=%%j

echo Begin copying PB executable zip files for database %%i to remote server at %cday% %ctime%

rem *call copyzips %2 %%i rackspac-1f8789\sybase_sa sybase %3 %4 > log\copyzips_%%i.log
call copyzips %2 %%i sybase_sa sybase %3 %4 > log\copyzips_%%i.log
							
echo File copy for PB exe %%i completed at %cday% %ctime%

rem update row to show copy is completed

)

:pbsrc
rem *** now zip and copy all pb apps src code from shadow drive
for /f "delims==" %%j IN ('date /T') DO set cday=%%j
for /f "delims==" %%j IN ('time /T') DO set ctime=%%j

echo Begin ziping up PowerBuilder Application files at %cday% %ctime%
for /f "delims==" %%i IN (' ^(type config\disast_pbsrc.conf^) ') DO (

rem call the procedure to unload source from vss
	call ss_unload.bat %%i c:\pbsrc %7> log\ss_unload%%i.log

rem zip it up

rem *	call wz.bat c:\pbsrc\zip\%%i.zip c:\pbsrc\*.* > log\wz_pbsrc.%%i
	call wz.bat %6\zip\%%ipb.zip %6\*.* > log\wz_pbsrc.%%i

rem now do copy to remote server

	for /f "delims==" %%j IN ('date /T') DO set cday=%%j
	for /f "delims==" %%j IN ('time /T') DO set ctime=%%j

	echo Begin copying PB zip files for database %%i to remote server at %cday% %ctime%

	call copyzips %2\src %%ipb sybase_sa sybase %6\zip %4 > log\copyzips_%%i.log
							
	echo File copy for PB Src %%i completed at %cday% %ctime%

rem update row to show copy is completed

)


for /f "delims==" %%j IN ('date /T') DO set cday=%%j
for /f "delims==" %%j IN ('time /T') DO set ctime=%%j

echo Disaster recovery copy completed at %cday% %ctime%..



