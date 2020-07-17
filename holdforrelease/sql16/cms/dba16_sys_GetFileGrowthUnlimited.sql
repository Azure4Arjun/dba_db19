SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- ======================================================================================
-- dba16_sys_GetFileGrowthUnlimited
--
--
-- Calls:		None
--
-- Description:	Get a listing of each DB file that has growth with percentage
--				and/or no limits set for max.
-- 
-- Date			Modified By			Changes
-- 09/18/2017   Aron E. Tekulsky    Initial Coding.
-- 01/01/2018   Aron E. Tekulsky    Update to V140.
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

	SET ARITHIGNORE ON

	DECLARE @command VARCHAR(5000)
	DECLARE @format tinyint
	DECLARE @SystemDB tinyint

	SET @format = 2; -- 0 Summary only, 1 verbose, 2 only unlimited growth db's

	SET @SystemDB = 1; -- 0 include systemdb, 1 Exclude systemdb

	SET ROWCOUNT 0;

	IF @format <> 0
		BEGIN
			CREATE TABLE #DBInfo2
				( ServerName VARCHAR(100),
				DatabaseName VARCHAR(100),
				type_desc nvarchar(60),
				FileSizeMB INT,
				LogicalFileName sysname,
				PhysicalFileName NVARCHAR(520),
				Status sysname,
				Updateability sysname,
				RecoveryMode sysname,
				FreeSpaceMB INT,
				FreeSpacePct VARCHAR(7),
				FreeSpacePages INT,
				PollDate datetime,
				maxsize int,
				growth int,
				is_percent_growth bit, -- 0, growth increment is in units of 8-KB pages - 1, growth increment is expressed as a whole number percentage.
				dbowner nvarchar(128))

			IF @SystemDB = 1 -- Exclude system db
				BEGIN
					SELECT @command = 'Use [' + '?' + '] IF
						''?'' <> ''master'' AND ''?'' <> ''model'' AND ''?'' <> ''msdb'' AND ''?'' <>
						''tempdb'' BEGIN SELECT
						@@servername as ServerName,
						' + '''' + '?' + '''' + ' AS DatabaseName, 
						sys.database_files.type_desc,
						CAST(sys.database_files.size/128.0 AS int) AS FileSize,
						sys.database_files.name AS LogicalFileName, sys.database_files.physical_name AS PhysicalFileName,
						CONVERT(sysname,DatabasePropertyEx(''?'',''Status'')) AS Status,
						CONVERT(sysname,DatabasePropertyEx(''?'',''Updateability'')) AS Updateability,
						CONVERT(sysname,DatabasePropertyEx(''?'',''Recovery'')) AS RecoveryMode,
						CAST(sys.database_files.size/128.0 -
						CAST(FILEPROPERTY(sys.database_files.name, ' + '''' +
						'SpaceUsed' + '''' + ' ) AS int)/128.0 AS int) AS FreeSpaceMB,
						CAST(100 * (CAST (((sys.database_files.size/128.0 -CAST(FILEPROPERTY(sys.database_files.name,
						' + '''' + 'SpaceUsed' +
						'''' + ' ) AS int)/128.0)/(sys.database_files.size/128.0)) AS decimal(4,2))) AS varchar(8)) + ' + '''' + '''' + ' AS FreeSpacePct, max_size, growth,
						is_percent_growth
							FROM sys.database_files' + ' END '
				END
			ELSE
				BEGIN -- include system db
					SELECT @command = 'Use [' + '?' + '] SELECT
						@@servername as ServerName,
						' + '''' + '?' + '''' + ' AS DatabaseName, database_files.type_desc,
						CAST(sys.database_files.size/128.0 AS int) AS FileSize,
						sys.database_files.name AS LogicalFileName, sys.database_files.physical_name AS PhysicalFileName,
						CONVERT(sysname,DatabasePropertyEx(''?'',''Status'')) AS Status,
						CONVERT(sysname,DatabasePropertyEx(''?'',''Updateability'')) AS Updateability,
						CONVERT(sysname,DatabasePropertyEx(''?'',''Recovery'')) AS RecoveryMode,
						CAST(sys.database_files.size/128.0 -
						CAST(FILEPROPERTY(sys.database_files.name, ' + '''' +
						'SpaceUsed' + '''' + ' ) AS int)/128.0 AS int) AS FreeSpaceMB,
						CAST(100 * (CAST (((sys.database_files.size/128.0 -CAST(FILEPROPERTY(sys.database_files.name,
						' + '''' + 'SpaceUsed' +
						'''' + ' ) AS int)/128.0)/(sys.database_files.size/128.0)) AS decimal(4,2))) AS
						varchar(8)) + ' + '''' + '''' + ' AS FreeSpacePct, max_size, growth,
						is_percent_growth
							FROM sys.database_files'
				END

			INSERT INTO #DBInfo2
				(ServerName,
				DatabaseName,
				type_desc,
				FileSizeMB,
				LogicalFileName,
				PhysicalFileName,
				Status,
				Updateability,
				RecoveryMode,
				FreeSpaceMB,
				FreeSpacePct,
				maxsize, growth ,
				is_percent_growth )
			EXEC sp_MSForEachDB @command;

			IF @format = 1
				BEGIN
					SELECT db.DatabaseName as DBName,
							db.LogicalFileName as DBLogicalFileName,
							db.PhysicalFileName as DBPhysicalFileName,
							db.RecoveryMode as DBRecoveryMode,
							db.FileSizeMB AS DBFileSizeMB,
							db.FreeSpaceMB as DBFreeSpaceMB,
							db.FreeSpacePct as DBFreeSpacePct,
							CASE maxsize
								WHEN 0 THEN 'No Growth'
								WHEN -1 THEN 'File will grow until disk is full'
								WHEN 268435456 THEN ' Log file will grow to a maximum size of 2 TB.'
							ELSE
								convert(varchar(128),(maxsize/128)) + ' MB'
							END as maxsize,
							CASE is_percent_growth
								WHEN 0 THEN
									growth/128
							ELSE
								growth
							END AS GrowthAmtMBPct,
							CASE is_percent_growth
								WHEN 0 THEN
									'MB'
							ELSE
								'Percentage'
							END AS GrowthType--,
						FROM #DBInfo2 db
					WHERE db.DatabaseName not in (
						SELECT DatabaseName
							FROM #DBInfo2 DB)
				UNION ALL
				SELECT	db.DatabaseName,
							db.LogicalFileName,
							db.PhysicalFileName,
							db.RecoveryMode,
							db.FileSizeMB,
							db.FreeSpaceMB as DBFreeSpaceMB,
							db.FreeSpacePct as DBFreeSpacePct,
							CASE maxsize
								WHEN 0 THEN 'No Growth'
								WHEN -1 THEN 'File will grow until disk is full'
								WHEN 268435456 THEN ' Log file will grow to a maximum size of 2 TB.'
							ELSE
								convert(varchar(128),(maxsize/128)) + ' MB'
							END as maxsize,
							CASE is_percent_growth
								WHEN 0 THEN
									growth/128
							ELSE
								growth
							END AS GrowthAmtMBPct,
							CASE is_percent_growth
								WHEN 0 THEN
									'MB'
							ELSE
								'Percentage'
							END AS GrowthType
						FROM #DBInfo2 db
					ORDER BY db.DatabaseName ASC, db.LogicalFileName, db.FreeSpacePct ASC
			END
	ELSE -- @format = 2 unlimited only
		BEGIN
			SELECT db.DatabaseName as DBName,
					db.LogicalFileName as DBLogicalFileName,
					db.PhysicalFileName as DBPhysicalFileName,
					db.RecoveryMode as DBRecoveryMode,
					db.FileSizeMB AS DBFileSizeMB,
					db.FreeSpaceMB as DBFreeSpaceMB,
					db.FreeSpacePct as DBFreeSpacePct,
					CASE maxsize
						WHEN 0 THEN 'No Growth'
						WHEN -1 THEN 'File will grow until disk is full'
						WHEN 268435456 THEN ' Log file will grow to a maximum size of 2 TB.'
					ELSE convert(varchar(128),(maxsize/128)) + ' MB'
					END as maxsize,
					CASE is_percent_growth
						WHEN 0 THEN
							growth/128
					ELSE
						growth
					END AS GrowthAmtMBPct,
					CASE is_percent_growth
						WHEN 0 THEN
							'MB'
					ELSE
						'Percentage'
					END AS GrowthType
				FROM #DBInfo2 db
			WHERE db.DatabaseName not in (
				SELECT DatabaseName
					FROM #DBInfo2 DB)
----AND maxsize IN ('-1','268435456')
		UNION ALL
		SELECT db.DatabaseName,
				db.LogicalFileName,
				db.PhysicalFileName,
				db.RecoveryMode,
				db.FileSizeMB,
				db.FreeSpaceMB as DBFreeSpaceMB,
				db.FreeSpacePct as DBFreeSpacePct,
				CASE maxsize
					WHEN 0 THEN 'No Growth'
					WHEN -1 THEN 'File will grow until disk is full'
					WHEN 268435456 THEN ' Log file will grow to a maximum size of 2 TB.'
				ELSE
					convert(varchar(128),(maxsize/128)) + ' MB'
				END as maxsize,
				CASE is_percent_growth
					WHEN 0 THEN
						growth/128
				ELSE
					growth
				END AS GrowthAmtMBPct,
				CASE is_percent_growth
					WHEN 0 THEN
						'MB'
				ELSE
					'Percentage'
				END AS GrowthType--,
			FROM #DBInfo2 db
		WHERE ----------LEN(dr.Drive) > 3
-- AND db.FreeSpacePct < 20
----------AND
			maxsize IN ('-1','268435456')
		ORDER BY db.DatabaseName ASC, db.LogicalFileName, db.FreeSpacePct ASC;
	END

	DROP TABLE #DBInfo2;
END
END
GO
