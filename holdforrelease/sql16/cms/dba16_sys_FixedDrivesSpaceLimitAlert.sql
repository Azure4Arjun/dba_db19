SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- ======================================================================================
-- dba16_sys_FixedDrivesSpaceLimitAlert
--
--
-- Calls:		None
--
-- Description:	
-- 
-- Date			Modified By			Changes
-- 10/02/2014   Aron E. Tekulsky    Initial Coding.
-- 01/02/2018   Aron E. Tekulsky    Update to V140.
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
	SET NOCOUNT ON

	DECLARE @SQL	NVARCHAR(1000)
	DECLARE @format tinyint

	SET @format = 1;

	CREATE TABLE #DrvLetter (
		Drive VARCHAR(500)
	)

	CREATE TABLE #DrvInfo (
		Drive			VARCHAR(500) null,
		[MB free]		DECIMAL(20,2),
		[MB TotalSize]	DECIMAL(20,2),
		[Volume Name]	VARCHAR(64)
	)

	INSERT INTO #DrvLetter
		EXEC xp_cmdshell 'wmic volume where Drivetype="3" get caption, freespace, capacity,label'

	DELETE
		FROM #DrvLetter
	WHERE Drive IS NULL OR len(Drive) < 4 OR Drive LIKE '%Capacity%'
	OR Drive LIKE '%\\%\Volume%';

	DECLARE @STRLine	VARCHAR(8000)
	DECLARE @Drive		varchar(500)
	DECLARE @TotalSize	REAL
	DECLARE @Freesize	REAL
	DECLARE @VolumeName VARCHAR(64)

	WHILE EXISTS(SELECT 1 FROM #DrvLetter)
		BEGIN
			SET ROWCOUNT 1;

			SELECT @STRLine = Drive FROM #DrvLetter;
-- Get TotalSize
			SET @TotalSize= CAST(LEFT(@STRLine,CHARINDEX(' ',@STRLine)) AS REAL)/1024/1024;
--SELECT @TotalSize

-- Remove Total Size
			SET @STRLine = REPLACE(@STRLine, LEFT(@STRLine,CHARINDEX(' ',@STRLine)),'');
-- Get Drive
			SET @Drive = LEFT(LTRIM(@STRLine),CHARINDEX(' ',LTRIM(@STRLine)));
--SELECT @Drive
			SET @STRLine = RTRIM(LTRIM(REPLACE(LTRIM(@STRLine), LEFT(LTRIM(@STRLine),CHARINDEX('',LTRIM(@STRLine))),'')));

			SET @Freesize = LEFT(LTRIM(@STRLine),CHARINDEX(' ',LTRIM(@STRLine)));
--SELECT @Freesize/1024/1024

			SET @STRLine = RTRIM(LTRIM(REPLACE(LTRIM(@STRLine), LEFT(LTRIM(@STRLine),CHARINDEX('',LTRIM(@STRLine))),'')));

			SET @VolumeName = @STRLine;
--
			INSERT INTO #DrvInfo
				SELECT @Drive, @Freesize/1024/1024 , @TotalSize, @VolumeName;

			DELETE FROM #DrvLetter

		END

	SET ROWCOUNT 0;

-- POPULATE TEMP TABLE WITH LOGICAL DISKS
-- This is FIX/Workaround for Windows 2003 bug that WMIC doesn't return volume name that is over X number of charactors.
	SET @SQL ='wmic /FailFast:ON logicaldisk where (Drivetype ="3" and
				volumename!="RECOVERY" AND volumename!="System Reserved") get deviceid,volumename
				/Format:csv';

	IF object_id('tempdb..#output1') IS NOT NULL DROP TABLE #output1;

	CREATE TABLE #output1 (Col1 VARCHAR(2048));

	INSERT INTO #output1
		EXEC master..xp_cmdshell @SQL;

	DELETE #output1 where ltrim(col1) is null or len(col1) = 1 or Col1 like'Node,DeviceID,VolumeName%';

	IF object_id('tempdb..#logicaldisk') IS NOT NULL DROP TABLE #logicaldisk;

	CREATE TABLE #logicaldisk (DeviceID varchar(128),VolumeName varchar(256));

	DECLARE @NodeName varchar(128)

	SET @NodeName = (SELECT TOP 1 LEFT(Col1, CHARINDEX(',',Col1)) FROM #output1);

-- Clean up server name
	UPDATE #output1 SET Col1 = REPLACE(Col1, @NodeName, '');

	INSERT INTO #logicaldisk
		SELECT LEFT(Col1, CHARINDEX(',',Col1)-2), SUBSTRING(COL1, CHARINDEX(',',Col1)+1,
				LEN(col1))
			FROM #output1;

	UPDATE dr
			SET dr.[Volume Name] = ld.VolumeName
		FROM #DrvInfo dr RIGHT OUTER JOIN #logicaldisk ld ON left(dr.Drive,1) = ld.DeviceID
	WHERE LEN([Volume Name]) = 1;

	IF @format = 0
		BEGIN
			SELECT CASE
					WHEN LEN(Drive) = 3 THEN LEFT(Drive,1)
					ELSE Drive
					END AS Drive,
					[MB free], [MB TotalSize], [Volume Name]
				FROM #DrvInfo
			ORDER BY 1;
		END
	ELSE IF @format = 1
			BEGIN
				CREATE TABLE #DBInfo2
					( ServerName VARCHAR(100),
						DatabaseName VARCHAR(100),
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
						statusval int,
						dbowner nvarchar(128))

				DECLARE @command VARCHAR(5000)

------------SELECT @command = 'Use [' + '?' + '] SELECT
------------@@servername as ServerName,
------------' + '''' + '?' + '''' + ' AS DatabaseName,
------------CAST(sysfiles.size/128.0 AS int) AS FileSize,
------------sysfiles.name AS LogicalFileName, sysfiles.filename ASPhysicalFileName,
------------CONVERT(sysname,DatabasePropertyEx(''?'',''Status'')) AS Status,
------------CONVERT(sysname,DatabasePropertyEx(''?'',''Updateability'')) ASUpdateability,
------------CONVERT(sysname,DatabasePropertyEx(''?'',''Recovery'')) ASRecoveryMode,
------------CAST(sysfiles.size/128.0 - CAST(FILEPROPERTY(sysfiles.name, ' +'''' +
------------ 'SpaceUsed' + '''' + ' ) AS int)/128.0 AS int) ASFreeSpaceMB,
------------CAST(100 * (CAST (((sysfiles.size/128.0-CAST(FILEPROPERTY(sysfiles.name,
------------' + '''' + 'SpaceUsed' + '''' + ' ) ASint)/128.0)/(sysfiles.size/128.0))
------------AS decimal(4,2))) AS varchar(8)) + ' + '''' + '''' + ' ASFreeSpacePct, maxsize, growth, status --20170630
--------------FROMbo.sysfiles'


				SELECT @command = 'Use [' + '?' + '] SELECT
						@@servername as ServerName,
						' + '''' + '?' + '''' + ' AS DatabaseName,
						CAST(sysfiles.size/128.0 AS int) AS FileSize,
							sysfiles.name AS LogicalFileName, sysfiles.filename AS PhysicalFileName,
						CONVERT(sysname,DatabasePropertyEx(''?'',''Status'')) AS Status,
						CONVERT(sysname,DatabasePropertyEx(''?'',''Updateability'')) AS
						Updateability,
						CONVERT(sysname,DatabasePropertyEx(''?'',''Recovery'')) AS RecoveryMode,
						CAST(sysfiles.size/128.0 - CAST(FILEPROPERTY(sysfiles.name, ' + '''' +
						'SpaceUsed' + '''' + ' ) AS int)/128.0 AS int) AS FreeSpaceMB,
						CAST(100 * (CAST (((sysfiles.size/128.0 -CAST(FILEPROPERTY(sysfiles.name,
						' + '''' + 'SpaceUsed' + '''' + ' ) AS int)/128.0)/(sysfiles.size/128.0))
						AS decimal(5,2))) AS varchar(8)) + ' + '''' + '''' + ' AS FreeSpacePct,
						maxsize, growth, status
					FROM dbo.sysfiles';

				INSERT INTO #DBInfo2
					(ServerName,
					DatabaseName,
					FileSizeMB,
					LogicalFileName,
					PhysicalFileName,
					Status,
					Updateability,
					RecoveryMode,
					FreeSpaceMB,
					FreeSpacePct,
					maxsize, growth , statusval )
				EXEC sp_MSForEachDB @command;

------------ *************************
----------SELECT 'middle ', *
---------- FROM #DBInfo2;
------------ *************************

				SELECT db.DatabaseName as DBName,
						db.LogicalFileName as DBLogicalFileName,
						db.PhysicalFileName as DBPhysicalFileName,
						db.RecoveryMode as DBRecoveryMode,
						db.FileSizeMB AS DBFileSizeMB,
						db.FreeSpaceMB as DBFreeSpaceMB,
						db.FreeSpacePct as DBFreeSpacePct,
						CASE
							WHEN LEN(dr.Drive) = 3 THEN LEFT(dr.Drive,1)
							ELSE dr.Drive
						END AS Drive,
						dr.[MB free] as DriveFreeSpaceMB,
						dr.[MB TotalSize] as DriveTotalSizeMB,
						CAST((dr.[MB free]/dr.[MB TotalSize]) * 100 AS NUMERIC(5,2)) as
						DriveFreeSpacePct,
						dr.[Volume Name],
						CASE maxsize
							WHEN 0 THEN 'No Growth'
							WHEN -1 THEN 'File will grow until disk is full'
							WHEN 268435456 THEN ' Log file will grow to a maximum size of 2 TB.'
							ELSE convert(varchar(128),(maxsize/128)) + ' MB'
						END as maxsize,
						CASE LEN(statusval)
							WHEN 1 THEN
								growth/128
							WHEN 2 THEN
								growth/128
							ELSE
								growth
						END AS GrowthAmtMBPct,
						CASE LEN(statusval)
							WHEN 1 THEN
								'MB'
							WHEN 2 THEN
								'MB'
							ELSE
								'Percentage'
						END AS GrowthType--,
--growth , statusval
					FROM #DBInfo2 db
						JOIN #DrvInfo dr ON LEFT(db.PhysicalFileName,LEN(dr.Drive)) = LEFT(dr.Drive,LEN(dr.Drive))
				WHERE db.DatabaseName not in (
						SELECT DatabaseName
							FROM #DBInfo2 DB
								JOIN (SELECT Drive FROM #DrvInfo 
						WHERE LEN(Drive) > 3) DR on LEFT(db.PhysicalFileName, LEN(Drive)) = DR.Drive)
							AND convert(decimal(5,2),db.FreeSpacePct) < 20.00--20170630
--------------------AND db.FreeSpacePct < '20' --20170630
--------------------AND CAST((dr.[MB free]/dr.[MBTotalSize]) * 100 AS NUMERIC(5,2)) <30 20170630
			UNION ALL
				SELECT db.DatabaseName,
							db.LogicalFileName,
							db.PhysicalFileName,
							db.RecoveryMode,
							db.FileSizeMB,
							db.FreeSpaceMB as DBFreeSpaceMB,
							db.FreeSpacePct as DBFreeSpacePct,
							CASE
								WHEN LEN(dr.Drive) = 3 THEN LEFT(dr.Drive,1)
								ELSE dr.Drive
							END AS Drive,
							dr.[MB free] AS DriveFreeSpaceMB, dr.[MB TotalSize] as
							DriveTotalSizeMB,
							CAST((dr.[MB free]/dr.[MB TotalSize]) * 100 AS NUMERIC(5,2)) as
							DriveFreeSpacePct,
							dr.[Volume Name],
							CASE maxsize
								WHEN 0 THEN 'No Growth'
								WHEN -1 THEN 'File will grow until disk is full'
								WHEN 268435456 THEN ' Log file will grow to a maximum size of 2 TB.'
								ELSE convert(varchar(128),(maxsize/128)) + ' MB'
							END as maxsize,
							CASE LEN(statusval)
								WHEN 1 THEN
									growth/128
								WHEN 2 THEN
									growth/128
								ELSE
									growth
							END AS GrowthAmtMBPct,
							CASE LEN(statusval)
								WHEN 1 THEN
									'MB'
								WHEN 2 THEN
									'MB'
								ELSE
									'Percentage'
							END AS GrowthType--,
--growth , statusval
						FROM #DBInfo2 db
							JOIN #DrvInfo dr ON LEFT(db.PhysicalFileName,LEN(dr.Drive)) = LEFT(dr.Drive,LEN(dr.Drive))
					WHERE LEN(dr.Drive) > 3
							AND convert(decimal(5,2),db.FreeSpacePct) < 20.00 --20170630
--------------------AND db.FreeSpacePct < '20' --20170630
--------------------AND CAST((dr.[MB free]/dr.[MBTotalSize]) * 100 AS NUMERIC(5,2)) <30 20170630
					ORDER BY db.FreeSpacePct ASC, db.DatabaseName ASC;

----------db.DatabaseName ASC, db.LogicalFileName, db.FreeSpacePct ASC

		DROP TABLE #DBInfo2;
	END

	DROP TABLE #logicaldisk;
	DROP TABLE #DrvLetter;
	DROP TABLE #DrvInfo
--END;
--GO
END
GO
