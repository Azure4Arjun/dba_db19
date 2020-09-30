--=================================================================
-- Author:		Aron E. Tekulsky
-- Create date: 2/08/10
-- Description: Script to move tempdb off of the c drive to an 
--              alternate drive .
--=================================================================

-- step 1 - set db off line

-- step 2 - alter the file location for each database to be moved.

--
-- DQS_MAIN ##MS_dqs_db_owner_login##
--

--ALTER DATABASE EDW 	MODIFY FILE (NAME = N'EDW', FILENAME = N'F:\DATA01\MSSQL\BIETLDEV\DATA01\EDW.mdf');
--ALTER DATABASE EDW 	MODIFY FILE (NAME = N'DQS_MAIN_log', FILENAME = N'L:\MSSQL\TRAN01\DQS_MAIN_log.ldf');
ALTER DATABASE Experiments 	MODIFY FILE (NAME = N'Experiments_log', FILENAME = N'F:\TRAN01\MSSQL\BIETLDEV\TRAN01\Experiments_log.ldf');

--
-- DQS_PROJECTS ##MS_dqs_db_owner_login##
--

--ALTER DATABASE DQS_PROJECTS MODIFY FILE (NAME = N'DQS_PROJECTS', FILENAME = N'M:\MSSQL\TRAN01\DQS_PROJECTS.mdf');
--ALTER DATABASE DQS_PROJECTS MODIFY FILE (NAME = N'DQS_PROJECTS_log', FILENAME = N'L:\MSSQL\TRAN01\DQS_PROJECTS_log.ldf');

----
---- DQS_STAGING_DATA ##MS_dqs_db_owner_login##
----

--ALTER DATABASE DQS_STAGING_DATA 	MODIFY FILE (NAME = N'DQS_STAGING_DATA', FILENAME = N'M:\MSSQL\TRAN01\DQS_STAGING_DATA.mdf');
--ALTER DATABASE DQS_STAGING_DATA 	MODIFY FILE (NAME = N'DQS_STAGING_DATA_log', FILENAME = N'L:\MSSQL\TRAN01\DQS_STAGING_DATA_log.ldf');

-- step 3
-- Move file or files to new location.

-- step 4
-- Set db on line

-- step 5
-- 5.Verify the file change by running the following query


-- DQS_MAIN 
SELECT name, physical_name AS CurrentLocation, state_desc
FROM sys.master_files
WHERE database_id = DB_ID(N'Experiments');

---- DQS_PROJECTS 
--SELECT name, physical_name AS CurrentLocation, state_desc
--FROM sys.master_files
--WHERE database_id = DB_ID(N'DQS_PROJECTS');

---- DQS_STAGING_DATA 
--SELECT name, physical_name AS CurrentLocation, state_desc
--FROM sys.master_files
--WHERE database_id = DB_ID(N'DQS_STAGING_DATA');


