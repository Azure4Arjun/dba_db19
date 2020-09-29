SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- ======================================================================================
-- dba19_sys_GetDBFiles
--
--
-- Calls:		None
--
-- Description:	Get a list of all DB files for each DB.
-- 
-- Date			Modified By			Changes
-- 04/13/2020   Aron E. Tekulsky    Initial Coding.
-- 04/13/2020   Aron E. Tekulsky    Update to Version 150.
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
	SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;

	SET ARITHIGNORE ON
	SET NOCOUNT ON

	DECLARE @command			NVARCHAR(4000)
	DECLARE @DBName				nvarchar(128)
	DECLARE @SQLVersion			int

	CREATE TABLE #DBInfo2
		(	ServerName			nvarchar(128), -- VARCHAR(100)
			DatabaseName		nvarchar(128), -- VARCHAR(100)
			LogicalFileName		nvarchar(128), -- sysname
			TypeDesc			nvarchar(60),
			FileGroup			nvarchar(128),
			FileSizeMB			varchar(20),
			FreeSpaceMB			float,
			FreeSpacePct		varchar(20), -- VARCHAR(7)
			Maxsize				varchar(20), -- sb int
			Growth				float, -- sb int
			IsPercentGrowth		bit,
			PhysicalFileName	nvarchar(260), -- NVARCHAR(520)
			Status				nvarchar(60), -- sysname
			Updateability		varchar(12), -- sysname
			RecoveryMode		nvarchar(60), --sysname
			)


	-- Initialize
	SET @DBName = 'test6';

-- Get SQL version running on server
	SET @SQLVersion = (SELECT substring((convert(nvarchar(128),serverproperty('productversion')) ),1, 2 ))	

	PRINT @SQLVersion
--
-- **** new code begin **
--

--**********************************
--* 1 Detail, 2 DB Detail Only     *
--**********************************

--
-- **** new code begin **
--
	DECLARE db_cur CURSOR FOR
		SELECT db.name
			FROM sys.databases db
		WHERE db.state = 0; -- online

	OPEN db_cur;

	FETCH NEXT FROM db_cur
		INTO
			@DBName;

	WHILE (@@FETCH_STATUS <> -1)
		BEGIN

	SET @command = 
	'USE [' + @DBName + '] ' +
	'	SELECT @@servername as ServerName, 
				DB_NAME(mf.database_id ) AS DatabaseName ,
				mf.name AS LogicalFileName, 
				mf.Type_Desc,
				ISNULL(g.name, ' + '''' + 'Not Applicable' + '''' +') AS FileGroup,
				mf.size / 128 AS FileSize,
				CAST(mf.size/128.0 - CAST(FILEPROPERTY(mf.name, ' + '''' +
					'SpaceUsed' + '''' + ' ) AS bigint)/128.0 AS bigint) AS FreeSpaceMB,
				CAST(100 * (CAST (((mf.size/128.0 -CAST(FILEPROPERTY(mf.name,
					' + '''' + 'SpaceUsed' + '''' + ' ) AS bigint)/128.0)/(mf.size/128.0))
					AS decimal(5,4))) AS varchar(16)) + ' + '''' + ''''
					+ ' AS FreeSpacePct,
				CASE mf.max_size 
					WHEN -1 THEN ' + '''' + 'UNLIMITED' + '''' + '
					ELSE CONVERT(varchar(20),mf.max_size)
				END AS MaxSize,
				mf.growth,
				mf.is_percent_growth,
				mf.physical_name, 
				mf.state_desc AS Status,
				CASE mf.is_read_only
					WHEN 1 THEN ' + '''' + 'READ_ONLY' + '''' + '
					ELSE ' + '''' + 'READ_WRITE' + '''' + '
				END AS Updateability,
				d.recovery_model_desc AS RecoveryMode						
			FROM sys.databases d
				JOIN sys.master_files mf ON (mf.database_id = d.database_id )
				JOIN sys.database_files df ON (df.name = mf.name ) AND
											(df.file_id = mf.file_id )
				LEFT JOIN sys.filegroups g ON (g.data_space_id = mf.data_space_id)
		ORDER BY mf.type ASC, mf.name ASC;';

	PRINT @command;

	INSERT INTO #DBInfo2
		(ServerName,
		DatabaseName,
		LogicalFileName,
		TypeDesc,
		FileGroup,
		FileSizeMB,
		FreeSpaceMB,
		FreeSpacePct,
		maxsize, 
		growth ,
		IsPercentGrowth,
		PhysicalFileName,
		Status,
		Updateability,
		RecoveryMode
		)
	EXEC (@command);

	print 'just did insert for ' + @DBName;
				
	FETCH NEXT FROM db_cur
		INTO
			@DBName;

	END
				
	CLOSE db_cur;

	DEALLOCATE db_cur;



	SELECT Servername,
			db.DatabaseName as DBName,
			db.LogicalFileName as DBLogicalFileName,
			db.TypeDesc, 
			ISNULL(db.FileGroup , 'N/A') as FileGroup,
			db.FileSizeMB AS [DBFileSize (MB)],
			db.FreeSpaceMB as [DBFreeSpace (MB)],
			db.FreeSpacePct as DBFreeSpacePct,
			CASE growth
				WHEN 0 THEN 0
				ELSE
					CASE db.IsPercentGrowth
					WHEN 1 THEN
						CONVERT(varchar(20), db.growth)
						ELSE
							CONVERT(varchar(20), (db.growth/128))
					END
			END AS [Growth (MB %)],
			--------			WHEN 0 THEN 'No Growth'
			--------------------WHEN -1 THEN 'File will grow until disk is full'
			--------			WHEN -1 THEN -1
			--------			WHEN 268435456 THEN ' Log file will grow to a maximum size of 2 TB.'
			--------			ELSE (convert(float,db.FileSizeMB) / convert(float,(maxsize/128))*100)
			--------		END
			CASE db.IsPercentGrowth
				WHEN 1 THEN '%'
				ELSE 'MB'
			END AS [MB %],
			db.Maxsize AS [Max Size (MB)],
			db.RecoveryMode as DBRecoveryMode,
			db.PhysicalFileName as DBPhysicalFileName,
			db.Status,
			db.Updateability,
			db.RecoveryMode
		FROM #DBInfo2 db
	WHERE upper(db.DatabaseName) = 'test7';

	DROP TABLE #DBInfo2;  --was testing
END
GO
