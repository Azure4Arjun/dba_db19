SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- ======================================================================================
-- dba16_sev_2007ListUnusedIndexesforAllDatabases
--
--
-- Calls:		None
--
-- Description:	2007 - List unused indexes for all databases.
--
-- From Edward Roepe - Perimeter DBA, LLC.  - www.perimeterdba.com
-- 
-- Date			Modified By			Changes
-- 09/08/2018   Aron E. Tekulsky    Initial Coding.
-- 06/10/2019   Aron E. Tekulsky    Update to Version 140.
-- ======================================================================================
--	Copyright©2001 - 2025 Aron Tekulsky.  World wide rights reserved.
--	Use of this code is free of charge but does not in any way imply transfer of 
--	Copyright ownership to the user.
-- ======================================================================================
--
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED

-- 2007 - List unused indexes for all databases
-- This script lists the indexes where the writes > reads
-- 03-26-2015 - ESR - Original program
-- 09-18-2017 - ESR - Updated for online databases

-- Change the write/read ratio as needed before running the script

-- Declare variables

	DECLARE @DatabaseName	VARCHAR(255);
	DECLARE @SQLCMD			VARCHAR(8000);

-- Initialize variables

-- Drop temp table for database names if it exists

	IF OBJECT_ID('tempdb..#DatabaseTable') IS NOT NULL
	    DROP TABLE #DatabaseTable;

-- Create temp table for database names

	CREATE TABLE #DatabaseTable
		(DatabaseName VARCHAR(255)
		);

-- Populate temp table for database names

	INSERT INTO #DatabaseTable(DatabaseName)
		SELECT a.name
			FROM master.sys.databases AS a
		WHERE a.database_id > 4
             AND state = 0
		ORDER BY a.name;

-- Drop temp table for data if it exists

	IF OBJECT_ID('tempdb..#DatabaseData') IS NOT NULL
	    DROP TABLE #DatabaseData;
    
-- Create temp table for data

	CREATE TABLE #DatabaseData
		(DatabaseName	VARCHAR(255), 
		SchemaName		VARCHAR(255), 
		ObjectName		VARCHAR(255), 
		IndexName		VARCHAR(255), 
		IndexId			BIGINT, 
		TotalWrites		BIGINT, 
		TotalReads		BIGINT, 
		Difference		BIGINT
		);

-- Create and open the cursor

	DECLARE Database_Cursor CURSOR FOR 
		SELECT DatabaseName
			FROM #DatabaseTable;

	OPEN Database_Cursor; 

-- Fetch the first record

	FETCH NEXT FROM Database_Cursor INTO @DatabaseName;

-- Loop thru the cursor

	WHILE @@FETCH_STATUS = 0
		BEGIN

        -- Create the command to run

			SELECT @SQLCMD = 'USE ['+@DatabaseName+']; '+'INSERT INTO #DatabaseData
					SELECT
							DB_NAME(),
							Object_schema_name(s.object_id),
							Object_name(s.object_id),
							i.name,
							i.index_id,
							user_updates,
							user_seeks + user_scans + user_lookups,
							user_updates - (user_seeks + user_scans + user_lookups )
						FROM sys.dm_db_index_usage_stats AS s WITH (NOLOCK)
							JOIN sys.indexes AS i WITH (NOLOCK) ON (s.object_id = i.object_id)
																AND (i.index_id = s.index_id)
					WHERE OBJECTPROPERTY(s.object_id, '+''''+'IsUserTable'+''''+') = 1
						AND s.database_id = DB_ID()
						AND user_updates > (user_seeks + user_scans + user_lookups)
						AND i.index_id > 1';

        -- print and/or execute the command

        -- PRINT @SQLCMD;
			EXEC (@SQLCMD);

        -- Fetch the next record

			FETCH NEXT FROM Database_Cursor INTO @DatabaseName;

		END;

-- Close and deallocate the cursor

	CLOSE Database_Cursor; 
	DEALLOCATE Database_Cursor; 

-- List the temp table

	SELECT SERVERPROPERTY('ServerName') AS 'InstanceName', 
			DatabaseName AS 'DatabaseName', 
			SchemaName AS 'SchemaName', 
			ObjectName AS 'TableName', 
			IndexName AS 'IndexName', 
			IndexId AS 'IndexId', 
			TotalWrites AS 'TotalWrites', 
			TotalReads AS 'TotalReads', 
			Difference AS 'Difference', 
			'USE ['+DatabaseName+']; DROP INDEX ['+IndexName+'] ON ['+SchemaName+'].['+ObjectName+'];' 
					AS 'DropCommand'
		FROM #DatabaseData
	WHERE Difference > 0
	ORDER BY Difference DESC, 
			TotalWrites DESC, 
			TotalReads ASC; 
  
END
GO
