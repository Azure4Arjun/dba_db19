@echo off
rem ***********************************************************************************
rem *	wz.bat                ****Generic****                                         *
rem *	                                                                              *
rem * 	Arguments:  %1	Dump file name and directory.   d:\sybase2\zip\iiedb1.zip     *
rem *		    %2	Zip file name and destination.  d:\sybase2\zip\iiedb1.dmp     *
rem *		    %3	Zip source directory.                                         *
rem *		    %3	servername                      \\usnypflpt1                  *
rem *		    %4	user				sybase_sa                     *
rem *		    %5	password						      *
rem *                                                                                 *
rem *	Description:	This script is run called by disast_master to zip up dump file*
rem *                                                                                 *
rem *	Date		By			Changes                               *
rem *	01/08/2004	Aron E. Tekulsky   Initial creation.                          *
rem *	05/04/2004	Aron E. Tekulsky   add code to allow for set up of device.    *
rem * 	11/17/2008	Aron E. Tekulsky   change to using localhost and winzip share.*
rem *                                                                                 *
rem ***********************************************************************************
rem e:
rem cd sybase\dumps											
 					 @echo on
echo one is %1												   
echo one was %1%
echo two is %2
echo two was %2%
echo three is %3

rem *set dest_server=%3
rem *set dest_user=%4
rem *set dest_pw=%5

rem *NET USE v: %dest_server% %dest_pw% /user:%dest_user%


cmd/c "\\localhost\winzip\wzzip.exe" %1 %2 -u -ex
rem ***cmd/c "c:\program files\winzip\wzzip.exe" %1 %2 -u -ex
rem cmd/c "c:\program files\winzip\wzzip.exe" %1 %2 -u -ex
rem c:\program files\winzip\wzzip.exe" %1 %2 -u -ex
rem 

rem *NET USE v: /DELETE

