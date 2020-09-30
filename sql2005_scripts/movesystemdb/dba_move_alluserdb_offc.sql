--=================================================================
-- Author:		Aron E. Tekulsky
-- Create date: 2/08/10
-- Description: Script to move tempdb off of the c drive to an 
--              alternate drive .
--=================================================================

-- step 1 - alter the file location for each database to be moved.
--E:\MSSQL10_50\MSSQL\Data\
--
-- Tempdb
----
--ALTER DATABASE tempdb MODIFY FILE (NAME = tempdev, FILENAME = 'E:\MSSQL10_50\MSSQL\Data\tempdb.mdf')
--GO

--ALTER DATABASE tempdb MODIFY FILE (NAME = templog, FILENAME = 'E:\MSSQL10_50\MSSQL\Data\templog.ldf')
--GO

--
-- Model
--
ALTER DATABASE model MODIFY FILE (NAME = modeldev, FILENAME = 'E:\MSSQL10_50\MSSQL\Data\modeldb.mdf')
GO

ALTER DATABASE model MODIFY FILE (NAME = modellog, FILENAME = 'E:\MSSQL10_50\MSSQL\Data\modellog.ldf')
GO
--
-- MSDB
--
ALTER DATABASE msdb MODIFY FILE (NAME = MSDBData, FILENAME = 'E:\MSSQL10_50\MSSQL\Data\MSDBData.mdf')
GO

ALTER DATABASE msdb MODIFY FILE (NAME = MSDBLog, FILENAME = 'E:\MSSQL10_50\MSSQL\Data\MSDBLog.ldf')
GO
--
-- Master
--
--ALTER DATABASE master MODIFY FILE (NAME = master, FILENAME = 'E:\MSSQL10_50\MSSQL\Data\master.mdf')
--GO

--ALTER DATABASE master MODIFY FILE (NAME = mastlog, FILENAME = 'E:\MSSQL10_50\MSSQL\Data\mastlog.ldf')
--GO

-- step 2
-- stop the instance of SQL Server

-- step 3
-- Move file or files to new location.

-- step 4
-- 4.Restart the instance of SQL Server or the server.

-- step 5
-- 5.Verify the file change by running the following query

-- tempdb
SELECT name, physical_name AS CurrentLocation, state_desc
FROM sys.master_files
WHERE database_id = DB_ID(N'tempdb');
go

-- model
SELECT name, physical_name AS CurrentLocation, state_desc
FROM sys.master_files
WHERE database_id = DB_ID(N'model');
go

-- msdb
SELECT name, physical_name AS CurrentLocation, state_desc
FROM sys.master_files
WHERE database_id = DB_ID(N'msdb');
go

---- master
--SELECT name, physical_name AS CurrentLocation, state_desc
--FROM sys.master_files
--WHERE database_id = DB_ID(N'master');
--go

-- 1.Verify that Service Broker is enabled for the msdb database by running the following query.
SELECT is_broker_enabled 
FROM sys.databases
WHERE name = N'msdb';

--2.Verify that Database Mail is working by sending a test mail.


-- master and system resources --
--1.From the Start menu, point to All Programs, point to Microsoft SQL Server 2005, point to Configuration Tools, and then click SQL Server Configuration Manager.

--2.In the SQL Server 2005 Services node, right-click the instance of SQL Server (for example, SQL Server (MSSQLSERVER)) and choose Properties.

--3.In the SQL Server (instance_name) Properties dialog box, click the Advanced tab.

--4.Edit the Startup Parameters values to point to the planned location for the master database data and log files, and click OK. Moving the error log file is optional.
--The parameter value for the data file must follow the -d parameter and the value for the log file must follow the -l parameter. The following example shows the parameter values for the default location of the master data and log files.
---dC:\Program Files\Microsoft SQL Server\MSSQL.1\MSSQL\DATA\master.mdf;-eC:\Program Files\Microsoft SQL Server\MSSQL.1\MSSQL\LOG\ERRORLOG;-lC:\Program Files\Microsoft SQL Server\MSSQL.1\MSSQL\DATA\mastlog.ldf

--5.Stop the instance of SQL Server by right-clicking the instance name and choosing Stop.

--6.Move the master.mdf and mastlog.ldf files to the new location.

--7.Start the instance of SQL Server in master-only recovery mode by entering one of the following commands at the command prompt. The parameters specified in these commands are case sensitive. The commands fail when the parameters are not specified as shown.

--For the default (MSSQLSERVER) instance, run the following command.
NET START MSSQLSERVER /f /T3608

--For a named instance, run the following command.
--Copy Code NET START MSSQL$instancename /f /T3608

--8.Using sqlcmd commands or SQL Server Management Studio, run the following statements. Change the FILENAME path to match the new location of the master data file. Do not change the name of the database or the file names.
-- you can use SQL Server Management Studio bu open a script only.  do not connect usong object explorer since you only have 1 connection.
ALTER DATABASE mssqlsystemresource 
    MODIFY FILE (NAME=data, FILENAME= 'E:\MSSQL10_50\MSSQL\Data\mssqlsystemresource.mdf');

ALTER DATABASE mssqlsystemresource 
    MODIFY FILE (NAME=log, FILENAME= 'E:\MSSQL10_50\MSSQL\Data\mssqlsystemresource.ldf');

--9.Move the mssqlsystemresource.mdf and mssqlsystemresource.ldf files to the new location.

--10.Set the Resource database to read-only by running the following statement.
ALTER DATABASE mssqlsystemresource SET READ_ONLY;

--11.Exit the sqlcmd utility or SQL Server Management Studio.

--12.Stop the instance of SQL Server.
NET STOP MSSQLSERVER

--13.Restart the instance of SQL Server.

--14.Verify the file change for the master database by running the following query. The Resource database metadata cannot be viewed by using the system catalog views or system tables.
SELECT name, physical_name AS CurrentLocation, state_desc
FROM sys.master_files
WHERE database_id = DB_ID('master');

