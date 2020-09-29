SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- ======================================================================================
-- dba19_sys_FixedDrivesSpaceLimitAlertB
--
--
-- Calls:		None
--
-- Description:	Get a listing of drives and db that are below 20 pct space left including tempdb.
-- 
-- Date			Modified By			Changes
-- 10/02/2014	Aron E. Tekulsky	Initial Coding.
-- 02/06/2018	Aron E. Tekulsky	Update to V130.
-- 07/19/2018	Aron E. Tekulsky	Add percentage of max.
-- 09/14/2018	Aron E. Tekulsky	add variable for %.
-- 10/08/2018	Aron E. Tekulsky	add ability to temporarily turn on
--									xp_cmdshell.
-- 10/30/2018	Aron E. Tekulsky	Add ability to set flag and limit to tempdb.
-- 08/25/2020   Aron E. Tekulsky    Update to Version 150.
-- ======================================================================================
--	Copyright©2001 - 2025 Aron Tekulsky.  World wide rights reserved.
--	Use of this code is free of charge but does not in any way imply transfer of 
--	Copyright ownership to the user.
--
--  This code and information are provided "AS IS" without warranty of
--  any kind, either expressed or implied, including but not limited
--  to the implied warranties of merchantability and/or fitness for a
--  particular purpose.
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

	DECLARE @command NVARCHAR(4000)
	DECLARE @Drive varchar(500)
	DECLARE @DetailSummaryFlag int
	DECLARE @format tinyint
	DECLARE @Freesize REAL
	------DECLARE @NodeName varchar(128)
	DECLARE @NodeName varchar(256)
	DECLARE @SQL NVARCHAR(1000)
	DECLARE @STRLine VARCHAR(8000)
	DECLARE @TotalSize REAL
	DECLARE @TempDBFlag int
	------DECLARE @VolumeName VARCHAR(64)
	------DECLARE @VolumeName VARCHAR(128)
	DECLARE @VolumeName VARCHAR(256)
	DECLARE @xpcmdshell int
	DECLARE @FreeMin Real
	DECLARE @putback int

	-- Initialize
	SET @DetailSummaryFlag = 0; -- 0 detal, 1 summery
	SET @TempDBFlag = 0; -- 0 all user db only 1 tempdb only
	SET @FreeMin = 100.00;

	SET @xpcmdshell = (SELECT convert(int,[value_in_use]) FROM [master].[sys].
		[configurations] WHERE [configuration_id] = 16390);

	PRINT convert(varchar(10),@xpcmdshell);

	SET @putback = @xpcmdshell;

	IF @xpcmdshell = 0
	BEGIN
		EXEC sp_configure 'XP_CmdShell','1';
	----GO
		RECONFIGURE WITH OVERRIDE;
	----GO
		SET @xpcmdshell = 1;
	END

	IF @xpcmdshell = 1
		SET @format = 1;
	ELSE
		SET @format = 2;

	PRINT 'format= ' + convert(char(10),@format);

	----------SET @format = 2; -- **** testing
	-- 0 - summary, 1 - detail, 2 - DB File only.

	IF @format <> 2
		BEGIN
			CREATE TABLE #DrvLetter (
				Drive VARCHAR(500),
			)

------CREATE TABLE #DrvInfo (
------ Drive VARCHAR(500) null,
------ [MB free] DECIMAL(20,2),
------ [MB TotalSize] DECIMAL(20,2),
------ [Volume Name] VARCHAR(64)
------)

			CREATE TABLE #DrvInfo (
				Drive VARCHAR(500) null,
				[MB free] DECIMAL(20,2),
				[MB TotalSize] DECIMAL(20,2),
				[Volume Name] VARCHAR(256)
			)

			INSERT INTO #DrvLetter
				EXEC xp_cmdshell 'wmic volume where Drivetype="3" get caption,
					freespace, capacity, label';

			DELETE
				FROM #DrvLetter
			WHERE Drive IS NULL OR len(Drive) < 4 OR Drive LIKE '%Capacity%'
				OR Drive LIKE '%\\%\Volume%';
			WHILE EXISTS(SELECT 1 FROM #DrvLetter)
				BEGIN
					SET ROWCOUNT 1;;

					SELECT @STRLine = Drive FROM #DrvLetter;
-- Get TotalSize
					------SET @TotalSize= CAST(LEFT(@STRLine,CHARINDEX('
					------',@STRLine)) AS REAL)/1024/1024;

					SET @TotalSize= CAST(LEFT(@STRLine,CHARINDEX(' ',@STRLine,0)) AS REAL)/1024/1024;

					--SELECT @TotalSize
					-- Remove Total Size

					SET @STRLine = REPLACE(@STRLine, LEFT(@STRLine,CHARINDEX('
						',@STRLine)),'');

	-- Get Drive
					SET @Drive = LEFT(LTRIM(@STRLine),CHARINDEX(' ',LTRIM
						(@STRLine)));

--SELECT @Drive
					SET @STRLine = RTRIM(LTRIM(REPLACE(LTRIM(@STRLine), LEFT
						(LTRIM(@STRLine),CHARINDEX(' ',LTRIM(@STRLine))),'')));

					SET @Freesize = LEFT(LTRIM(@STRLine),CHARINDEX(' ',LTRIM
						(@STRLine)));

--SELECT @Freesize/1024/1024
					SET @STRLine = RTRIM(LTRIM(REPLACE(LTRIM(@STRLine), LEFT
						(LTRIM(@STRLine),CHARINDEX(' ',LTRIM(@STRLine))),'')));

					SET @VolumeName = @STRLine;
	--
					INSERT INTO #DrvInfo
						SELECT @Drive, @Freesize/1024/1024 , @TotalSize,
							@VolumeName;

					DELETE FROM #DrvLetter;
				END

			SET ROWCOUNT 0

			-- POPULATE TEMP TABLE WITH LOGICAL DISKS
-- This is FIX/Workaround for Windows 2003 bug that WMIC doesn't return volume
--name that is over X number of charactors.

			SET @SQL ='wmic /FailFast:ON logicaldisk where (Drivetype ="3" and
				volumename!="RECOVERY" AND volumename!="System Reserved") get
				deviceid,volumename /Format:csv';

			IF object_id('tempdb..#output1') IS NOT NULL DROP TABLE #output1;

			CREATE TABLE #output1 (Col1 VARCHAR(2048));
			
			INSERT INTO #output1
				EXEC master..xp_cmdshell @SQL;

			DELETE #output1 where ltrim(col1) is null or len(col1) = 1 or Col1
				like 'Node,DeviceID,VolumeName%';

			IF object_id('tempdb..#logicaldisk') IS NOT NULL DROP TABLe
				#logicaldisk;

------CREATE TABLE #logicaldisk (DeviceID varchar(128),VolumeName
--varchar(256));

			CREATE TABLE #logicaldisk (DeviceID varchar(256),VolumeName varchar
				(256));

--DECLARE @NodeName varchar(128)

			SET @NodeName = (SELECT TOP 1 LEFT(Col1, CHARINDEX(',',Col1)) FROM
				#output1);

-- Clean up server name
			UPDATE #output1 SET Col1 = REPLACE(Col1, @NodeName, '');

			INSERT INTO #logicaldisk
				SELECT LEFT(Col1, CHARINDEX(',',Col1)-2), SUBSTRING(COL1,
						CHARINDEX(',',Col1)+1, LEN(col1))
					FROM #output1;

			UPDATE dr
				SET dr.[Volume Name] = ld.VolumeName
					FROM #DrvInfo dr RIGHT OUTER JOIN #logicaldisk ld ON left
						(dr.Drive,1) = ld.DeviceID
				WHERE LEN([Volume Name]) = 1;
		END

		IF @format = 0 -- Summary only
			BEGIN
				SELECT CASE
					WHEN LEN(Drive) = 3 THEN LEFT(Drive,1)
					ELSE Drive
				END AS Drive,
					[MB free], [MB TotalSize], [Volume Name]
					FROM #DrvInfo
				ORDER BY 1;
			END

		ELSE IF @format = 1 OR @format = 2 -- Detail or DB detail only.
				BEGIN
					CREATE TABLE #DBInfo2
						( ServerName NVARCHAR(128),
						DatabaseName NVARCHAR(128),
						FileSizeMB bigint,
						LogicalFileName sysname,
						PhysicalFileName NVARCHAR(4000),
						Status sysname,
						Updateability sysname,
						RecoveryMode sysname,
						FreeSpaceMB bigint,
						FreeSpacePct NVARCHAR(16),
						FreeSpacePages bigint,
						PollDate datetime,
						maxsize bigint,
						growth bigint,
						statusval int,
						dbowner nvarchar(128))

					SELECT @command = 'Use [' + '?' + '] SELECT
							@@servername as ServerName,
							' + '''' + '?' + '''' + ' AS DatabaseName,
							CAST(sysfiles.size/128.0 AS bigint) AS FileSize,
							sysfiles.name AS LogicalFileName, sysfiles.filename AS
							PhysicalFileName,
							CONVERT(sysname,DatabasePropertyEx(''?'',''Status'')) AS
							Status,
							CONVERT(sysname,DatabasePropertyEx(''?'',''Updateability''))
							AS Updateability,
							CONVERT(sysname,DatabasePropertyEx(''?'',''Recovery'')) AS
							RecoveryMode,
							CAST(sysfiles.size/128.0 - CAST(FILEPROPERTY(sysfiles.name, '
							+ '''' +
							'SpaceUsed' + '''' + ' ) AS bigint)/128.0 AS bigint)
							AS FreeSpaceMB,
							CAST(100 * (CAST (((sysfiles.size/128.0 -CAST(FILEPROPERTY
							(sysfiles.name,
							' + '''' + 'SpaceUsed' + '''' + ' ) AS bigint)/128.0)/
							(sysfiles.size/128.0))
							AS decimal(5,4))) AS varchar(16)) + ' + '''' + '''' + ' AS
							FreeSpacePct, maxsize, growth, status
						FROM dbo.sysfiles' ;

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
				EXEC sp_MSForEachDB @command ;

				IF @format = 1 -- Detail only
					BEGIN
						IF @TempDBFlag = 1
							BEGIN
								IF @DetailSummaryFlag = 1
									BEGIN
										CREATE TABLE #SummaryDBInfo2 -- do
			--insert to this table then either just select all or select
			--with summaries.

											( ServerName NVARCHAR(128),
											DatabaseName NVARCHAR(128),
											LogicalFileName sysname,
											PhysicalFileName NVARCHAR(4000),
											RecoveryMode sysname,
											DBFileSizeMB bigint,
											DBFreeSpaceMB decimal(12,2),
											DBFreeSpacePct decimal(7,4),
											DBMaxsize nvarchar(128),
											GrowthAmtMBPct real,
											GrowthType varchar(10),
											Drive varchar(10),
											DriveFreeSpaceMB decimal(12,2),
											DriveTotalSizeMB decimal(12,2),
											DriveFreeSpacePct real,
											DriveMaxUsable decimal(12,2),
											VolumeName nvarchar(128)
											)
									END

								SELECT --@@Servername(),
										db.DatabaseName as DBName,
										db.LogicalFileName as DBLogicalFileName,
										db.PhysicalFileName as DBPhysicalFileName,
										db.RecoveryMode as DBRecoveryMode,
										db.FileSizeMB AS DBFileSizeMB,
										db.FreeSpaceMB as DBFreeSpaceMB,
										db.FreeSpacePct as DBFreeSpacePct,
										CASE maxsize
											WHEN 0 THEN 'No Growth'
											WHEN -1 THEN 'File will grow until disk is
													full'
											WHEN 268435456 THEN ' Log file will grow to a
													maximum size of 2 TB.'
											ELSE convert(varchar(128),(maxsize/128)) + '
													MB'
										END as DBMaxsize,
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
										END AS GrowthType,
										CASE
											WHEN LEN(dr.Drive) = 3 THEN LEFT(dr.Drive,1)
											ELSE dr.Drive
										END AS Drive,
										dr.[MB free] as DriveFreeSpaceMB,
										dr.[MB TotalSize] as DriveTotalSizeMB,
										CAST((dr.[MB free]/dr.[MB TotalSize]) * 100 AS
										NUMERIC(5,2)) as DriveFreeSpacePct,
										dr.[MB TotalSize] * .8 AS DriveMaxUsable,
										dr.[Volume Name]--,
									FROM #DBInfo2 db
										JOIN #DrvInfo dr ON LEFT(db.PhysicalFileName,LEN(dr.Drive)) = LEFT(dr.Drive,LEN(dr.Drive))
								WHERE db.DatabaseName NOT IN (
										SELECT DatabaseName
											FROM #DBInfo2 DB
												JOIN (SELECT Drive 
														FROM #DrvInfo WHERE LEN(Drive) > 3) DR on LEFT(db.PhysicalFileName, LEN(Drive)) = DR.Drive)
																					AND upper(db.DatabaseName) IN ('TEMPDB')
																					AND convert(decimal(5,2),db.FreeSpacePct) < @FreeMin --20.00--20170630
																					AND upper(db.DatabaseName) IN ('TEMPDB')
						UNION ALL
					SELECT --@@Servername(),
							db.DatabaseName,
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
								ELSE convert(varchar(128),(maxsize/128)) + 'MB'
							END as DBMaxsize,
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
							END AS GrowthType,
							CASE
								WHEN LEN(dr.Drive) = 3 THEN LEFT(dr.Drive,1)
								ELSE dr.Drive
							END AS Drive,
							dr.[MB free] AS DriveFreeSpaceMB, dr.[MB
							TotalSize] as DriveTotalSizeMB,
							CAST((dr.[MB free]/dr.[MB TotalSize]) * 100 AS
							NUMERIC(5,2)) as DriveFreeSpacePct,
							dr.[MB TotalSize] * .8 AS DriveMaxUsable,
							dr.[Volume Name]
						FROM #DBInfo2 db
							JOIN #DrvInfo dr ON LEFT(db.PhysicalFileName,LEN(dr.Drive)) = LEFT(dr.Drive,LEN(dr.Drive))
					WHERE LEN(dr.Drive) > 3
						AND upper(db.DatabaseName) IN ('TEMPDB')
----------AND upper(db.DatabaseName) NOT IN
----('MASTER','MODEL','TEMPDB','MSDB')
						AND convert(decimal(5,2),db.FreeSpacePct) < @FreeMin
--20.00 --20170630
					ORDER BY db.FreeSpacePct ASC, db.DatabaseName ASC;
				END IF @TempDBFlag = 0
-- *****************************************************
-- * *
-- * flag is 0 *
--******************************************************
				SELECT --@@Servername(),
						db.DatabaseName as DBName,
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
						END as DBMaxsize,
						CASE LEN(statusval)
							WHEN 1 THEN growth/128
							WHEN 2 THEN growth/128
							ELSE growth
						END AS GrowthAmtMBPct,
						CASE LEN(statusval)
							WHEN 1 THEN 'MB'
							WHEN 2 THEN 'MB'
							ELSE 'Percentage'
						END AS GrowthType,
						CASE
							WHEN LEN(dr.Drive) = 3 THEN LEFT(dr.Drive,1)
							ELSE dr.Drive
						END AS Drive,
						dr.[MB free] as DriveFreeSpaceMB,
						dr.[MB TotalSize] as DriveTotalSizeMB,
						CAST((dr.[MB free]/dr.[MB TotalSize]) * 100 AS NUMERIC(5,2)) as DriveFreeSpacePct,
						dr.[MB TotalSize] * .8 AS DriveMaxUsable,
						dr.[Volume Name]--,
					FROM #DBInfo2 db
						JOIN #DrvInfo dr ON LEFT(db.PhysicalFileName,LEN(dr.Drive)) = LEFT(dr.Drive,LEN(dr.Drive))
				WHERE db.DatabaseName NOT IN (
							SELECT DatabaseName
								FROM #DBInfo2 DB
									JOIN (SELECT Drive FROM #DrvInfo 
							WHERE LEN(Drive) > 3) DR on LEFT(db.PhysicalFileName, LEN(Drive)) = DR.Drive)
														AND upper(db.DatabaseName) IN ('TEMPDB')
														AND convert(decimal(5,2),db.FreeSpacePct) < @FreeMin --20.00--20170630
														AND upper(db.DatabaseName) NOT IN ('MASTER','MODEL','TEMPDB','MSDB')
			UNION ALL
				SELECT --@@Servername(),
						db.DatabaseName,
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
							ELSE convert(varchar(128),(maxsize/128)) + ' MB'
						END as DBMaxsize,
						CASE LEN(statusval)
							WHEN 1 THEN growth/128
							WHEN 2 THEN growth/128
							ELSE growth
						END AS GrowthAmtMBPct,
						CASE LEN(statusval)
							WHEN 1 THEN 'MB'
							WHEN 2 THEN 'MB'
							ELSE 'Percentage'
						END AS GrowthType,
						CASE
							WHEN LEN(dr.Drive) = 3 THEN LEFT(dr.Drive,1)
							ELSE dr.Drive
						END AS Drive,
						dr.[MB free] AS DriveFreeSpaceMB, dr.[MB TotalSize] as DriveTotalSizeMB,
						CAST((dr.[MB free]/dr.[MB TotalSize]) * 100 AS NUMERIC(5,2)) as DriveFreeSpacePct,
						dr.[MB TotalSize] * .8 AS DriveMaxUsable,
						dr.[Volume Name]
					FROM #DBInfo2 db
						JOIN #DrvInfo dr ON LEFT(db.PhysicalFileName,LEN(dr.Drive)) = LEFT(dr.Drive,LEN(dr.Drive))
				WHERE LEN(dr.Drive) > 3
			--------AND upper(db.DatabaseName) IN ('TEMPDB')
					AND upper(db.DatabaseName) NOT IN ('MASTER','MODEL','TEMPDB','MSDB')
					AND convert(decimal(5,2),db.FreeSpacePct) < @FreeMin
					--20.00 --20170630
				ORDER BY db.FreeSpacePct ASC, db.DatabaseName ASC;
			END

	ELSE IF @format = 2 -- DB info only
			BEGIN
				SELECT --@@Servername(),
						db.DatabaseName as DBName,
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
						CASE LEN(statusval)
							WHEN 1 THEN growth/128
							WHEN 2 THEN growth/128
							ELSE growth
						END AS GrowthAmtMBPct,
						CASE LEN(statusval)
							WHEN 1 THEN 'MB'
							WHEN 2 THEN 'MB'
							ELSE 'Percentage'
						END AS GrowthType,
						'' AS Drive, -- dummy columns
						0.0 AS DriveFreeSpaceMB,-- dummy columns
						0.0 AS DriveTotalSizeMB, -- dummy columns
						0 AS DriveFreeSpacePct,-- dummy columns
						0 AS DriveMaxUsable,
						'' AS [Volume Name],-- dummy columns
						CASE maxsize
							WHEN 0 THEN 0
							WHEN -1 THEN 0
							WHEN 268435456 THEN 0
						ELSE CASE db.FreeSpaceMB
								WHEN 0 THEN 0
								ELSE ((maxsize/128)/db.FreeSpaceMB)
							END
						END as MaxSizeFreePct
					FROM #DBInfo2 db
				WHERE db.DatabaseName NOT IN (
							SELECT DatabaseName
								FROM #DBInfo2 DB)
									AND upper(db.DatabaseName) IN ('TEMPDB')
							----------AND upper(db.DatabaseName) NOT IN ('MASTER','MODEL','TEMPDB','MSDB')
									AND convert(decimal(5,2),db.FreeSpacePct) < @FreeMin
							--20.00--20170630
						--------------------AND db.FreeSpacePct < '20' --20170630
						--------------------AND CAST((dr.[MB free]/dr.[MB TotalSize]) * 100 AS NUMERIC(5,2)) <30 20170630
			UNION ALL
				SELECT --@@Servername(),
						db.DatabaseName,
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
							ELSE convert(varchar(128),(maxsize/128)) + ' MB'
						END as maxsize,
						CASE LEN(statusval)
							WHEN 1 THEN growth/128
							WHEN 2 THEN growth/128
							ELSE growth
						END AS GrowthAmtMBPct,
						CASE LEN(statusval)
							WHEN 1 THEN 'MB'
							WHEN 2 THEN 'MB'
							ELSE 'Percentage'
						END AS GrowthType,
						'' AS Drive, -- dummy columns
						0.0 AS DriveFreeSpaceMB,-- dummy columns
						0.0 AS DriveTotalSizeMB, -- dummy columns
						0 AS DriveFreeSpacePct,-- dummy columns
						0 AS DriveMaxUsable,
						'' AS [Volume Name],-- dummy columns
						CASE maxsize
							WHEN 0 THEN 0
							WHEN -1 THEN 0
							WHEN 268435456 THEN 0
							ELSE CASE db.FreeSpaceMB
										WHEN 0 THEN 0
										ELSE ((maxsize/128)/db.FreeSpaceMB)
									END
						END as MaxSizeFreePct
					FROM #DBInfo2 db
					----------WHERE upper(db.DatabaseName) NOT IN ('MASTER','MODEL','TEMPDB','MSDB')
				WHERE upper(db.DatabaseName) IN ('TEMPDB')
						AND convert(decimal(5,2),db.FreeSpacePct) < @FreeMin
					-- 20.00 --20170630
				ORDER BY db.DatabaseName ASC, db.LogicalFileName ASC, db.FreeSpacePct ASC;
			------ORDER BY db.FreeSpacePct ASC, db.DatabaseName ASC;
		END

	DROP TABLE #DBInfo2;
END

	IF @format <> 2
		BEGIN
			DROP TABLE #logicaldisk;
			DROP TABLE #DrvLetter;
			DROP TABLE #DrvInfo;
		END

	IF @putback = 0
	BEGIN
		EXEC sp_configure 'XP_CmdShell', '0';
----GO
		RECONFIGURE WITH OVERRIDE ;
----GO
	END

END
GO
