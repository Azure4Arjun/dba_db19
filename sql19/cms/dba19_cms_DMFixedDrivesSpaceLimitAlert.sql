SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- ======================================================================================
-- dba19_cms_DMFixedDrivesSpaceLimitAlert
--
--
-- Calls:		None
--
-- Description:	
-- 
-- Date			Modified By			Changes
-- 10/02/2014   Aron E. Tekulsky    Initial Coding.
-- 01/02/2018   Aron E. Tekulsky    Update to V140.
-- 07/19/2018	Aron E. Tekulsky	Add percentage of max.
-- 09/14/2018	Aron E. Tekulsky	add variable for %.
-- 10/08/2018	Aron E. Tekulsky	add ability to temporarily turn on xp_cmdshell.
-- 10/30/2018	Aron E. Tekulsky	Add ability to set flag and limit to tempdb.
-- 11/28/2018	Aron E. Tekulsky	Add DriveMaxUsablePct to show how much of the
--									usable space on the drive is available.
-- 01/23/2019	Aron E. Tekulsky	Add DBMaxsizePct to show the percentage of
--									the current file size is of the max
--									allowable growth size.
-- 02/07/2019	Aron E. Tekulsky	Change DBMaxsize to not have 'MB' in row
--									and update heade to have 'MB'.
-- 02/07/2019	Aron E. Tekulsky	When growth is 0 say 0.
-- 03/01/2019	Aron E. Tekulsky	Add @FreeMax to allow for filter by
--									dbfile max %.
-- 03/18/2019	Aron E. Tekulsky	sort by DBMaxsizePct ASC first.
-- 05/07/2019	Aron E. Tekulsky	eliminate mp name 
--									restriction.LEN(dr.VolumeMountPoint) > 3.
-- 08/13/2019	Aron E. Tekulsky	eliminate poll date fom #dbinfo2.  
--									It was unused and causing an issue.
-- 09/24/2019	Aron E. Tekulsky	Add DBMaxSize.
-- 04/28/2020	Aron E. Tekulsky	Add drive free space pct to @VolumeSpaces.
--									Filter by db free space < @FreeMin or
--									disk space free < @DiskFreeMin.
--									disk space free < @DiskFreeMin.
-- 08/14/2020   Aron E. Tekulsky    Update to Version 150.
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
---
--- use get disk space for all db.  att physical to it.  get all db and cursor through setting up fo each db as script and executing it to load up table.
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
	----DECLARE @Drive				varchar(500)
	DECLARE @DetailSummaryFlag	int
	DECLARE @format				tinyint
	----DECLARE @Freesize			REAL
------DECLARE @NodeName varchar(128)
	----DECLARE @NodeName			varchar(256)
	----DECLARE @SQL				NVARCHAR(1000)
	DECLARE @SQLVersion			int
	----DECLARE @STRLine			VARCHAR(8000)
	----DECLARE @TotalSize			REAL
	DECLARE @TempDBFlag			int
------DECLARE @VolumeName VARCHAR(64)
------DECLARE @VolumeName VARCHAR(128)
	----DECLARE @VolumeName			VARCHAR(256)
	----DECLARE @xpcmdshell			int

	DECLARE @FreeMin			Real
	DECLARE @FreeMax			Real
	DECLARE @DiskFreeMin		real
	DECLARE @DiskFreeMax		real
	----DECLARE @putback			int

	DECLARE @VolumeSpaces AS TABLE (
		VolumeMountPoint		nvarchar(512), -- disk
		----VolumeId			nvarchar(512),
		LogicalVolumeName		nvarchar(512),
		FileSystemType			nvarchar(512),
		TotalMB					float, -- total
		AvailableMB				float, -- free
		UsedSpace				float, -- used 
		EightyPercent			float,
		--------------------DriveFreeSpacePct		float,  -- new
		DriveFreeSpacePct		varchar(20),  -- new
		MaxUsable				float,
		databaseid				int,
		fileid					int)

	CREATE TABLE #DBInfo2
		(	ServerName			NVARCHAR(128), -- VARCHAR(100)
			DatabaseName		NVARCHAR(128), -- VARCHAR(100)
			FileSizeMB			float,
			LogicalFileName		nvarchar(128), -- sysname
			PhysicalFileName	NVARCHAR(260), -- NVARCHAR(520)
			Status				nvarchar(60), -- sysname
			Updateability		varchar(12), -- sysname
			RecoveryMode		nvarchar(60), --sysname
			FreeSpaceMB			float,
			FreeSpacePct		VARCHAR(20), -- VARCHAR(7)
			FreeSpacePages		float, -- was int and then bigint
			--------------------PollDate			datetime, -- eliminated not used 8/13/2019 AET
			maxsize				float, -- sb int
			growth				float, -- sb int
			databaseid			int,
			fileid				int,
			statusval			bit
			------statusval			bit,
			------databaseid			int,
			------fileid				int
			----dbowner				nvarchar(128)
			)


	-- Initialize
	SET @DetailSummaryFlag	= 0; -- 0 detail, 1 summery
	SET @TempDBFlag			= 0; -- 0 all user db only 1 tempdb only
	------------SET @FreeMin			= 100.00;
	SET @FreeMin			= 10.00;
	SET @FreeMax			= 80.00;
	SET @DiskFreeMin		= 95.00;
	SET @DiskFreeMax		= 80.00;

	------SET @format = 1;
-- Get SQL version running on server
	SET @SQLVersion = (SELECT substring((convert(nvarchar(128),serverproperty('productversion')) ),1, 2 ))	

	PRINT @SQLVersion

	----------SET	@xpcmdshell = (SELECT convert(int,[value_in_use]) FROM [master].[sys].
	----------	[configurations] WHERE [configuration_id] = 16390);

	----------PRINT convert(varchar(10),@xpcmdshell);

	----------SET @putback = @xpcmdshell;

	----------IF @xpcmdshell = 0
	----------	BEGIN
	----------		EXEC sp_configure 'XP_CmdShell','1';
	----------	----GO
	----------		RECONFIGURE WITH OVERRIDE;
	----------	----GO
	----------		SET @xpcmdshell = 1;
	----------	END

	----------IF @xpcmdshell = 1
	----------	SET @format = 1;
	----------ELSE
	----------	SET @format = 2;

	PRINT 'format= ' + convert(char(10),@format);
	SET @format = 1; -- **** testing
	-- 0 - summary, 1 - detail, 2 - DB File only.
--
-- **** new code begin **
--
			
--
-- **** new code END **
--


--
-- **** new code begin **
--
	INSERT INTO @VolumeSpaces 
		(VolumeMountPoint,--VolumeId,
				LogicalVolumeName,FileSystemType, TotalMB, AvailableMB, UsedSpace, EightyPercent, 
				DriveFreeSpacePct, 
				MaxUsable,
				databaseid,fileid)
	SELECT DISTINCT vs.volume_mount_point AS [Drive],
			----vs.volume_id ,
			vs.logical_volume_name AS [Drive Name],
			vs.file_system_type ,
			vs.total_bytes/1024/1024 AS [Drive Size MB],
			vs.available_bytes/1024/1024 AS [Drive Free Space MB],
			((vs.total_bytes - vs.available_bytes)/1024/1024 ) AS UsedSpace,
			(vs.total_bytes/1024/1024)*.8 AS EightyPercent,
			(CONVERT(float,(vs.available_bytes/1024/1024))/CONVERT(float,(vs.total_bytes/1024/1024)) * 100 ) as DriveFreeSpacePct,
			CASE 
				WHEN (((vs.total_bytes)*.8) - ((vs.total_bytes - vs.available_bytes))) > 0 THEN
					(((vs.total_bytes)*.8) - ((vs.total_bytes - vs.available_bytes))) /1024/1024 
				ELSE 0
			END AS MaxUsable,
			f.database_id , f.file_id
		FROM sys.master_files AS f
			CROSS APPLY sys.dm_os_volume_stats(f.database_id, f.file_id) AS vs
	ORDER BY vs.volume_mount_point;


--
-- **** new code END **
--


	IF @format = 0  -- Summary only
--**********************************
--* 0 Summary only *
--**********************************
		BEGIN
--
-- **** new code begin **
--

	SELECT VolumeMountPoint,--VolumeId,
			AvailableMB AS DAvailMB, TotalMB AS DTotMB, LogicalVolumeName
		FROM @VolumeSpaces
	ORDER BY VolumeMountPoint ASC;


--
-- **** new code END **
--

		END
	ELSE IF @format = 1 OR @format = 2 -- Detail or DB detail only.

--**********************************
--* 1 Detail, 2 DB Detail Only     *
--**********************************
			BEGIN

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
				'	SELECT @@servername as ServerName, DB_NAME(mf.database_id ) AS DatabaseName ,
							mf.size / 128 AS FileSize,
							mf.name AS LogicalFileName, mf.physical_name
							,mf.state_desc AS Status,
							CASE mf.is_read_only
								WHEN 1 THEN ' + '''' + 'READ_ONLY' + '''' + '
								ELSE ' + '''' + 'READ_WRITE' + '''' + '
							END AS Updateability,
							d.recovery_model_desc AS RecoveryMode,
							CAST(mf.size/128.0 - CAST(FILEPROPERTY(mf.name, ' + '''' +
								'SpaceUsed' + '''' + ' ) AS bigint)/128.0 AS bigint) AS FreeSpaceMB,
							CAST(100 * (CAST (((mf.size/128.0 -CAST(FILEPROPERTY(mf.name,
								' + '''' + 'SpaceUsed' + '''' + ' ) AS bigint)/128.0)/(mf.size/128.0))
								AS decimal(5,4))) AS varchar(16)) + ' + '''' + ''''
								+ ' AS FreeSpacePct
							,mf.max_size , mf.growth,
							mf.database_id, mf.file_id,
							mf.is_percent_growth
						FROM sys.databases d
							JOIN sys.master_files mf ON (mf.database_id = d.database_id )
							JOIN sys.database_files df ON (df.name = mf.name ) AND
														(df.file_id = mf.file_id );'

					PRINT @command;

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
					maxsize, growth ,
					databaseid,
					fileid, 
					statusval )
				EXEC (@command);

				print 'just did insert for ' + @DBName;
				
				FETCH NEXT FROM db_cur
					INTO
						@DBName;

				END
				
				CLOSE db_cur;

				DEALLOCATE db_cur;

				------------SELECT *
				------------	FROM @VolumeSpaces;

				------------SELECT 'dbinfo2 ',*
				------------FROM #DBInfo2; --testing;

				-- testing begin

				------------PRINT 'format = ' + convert(varchar(100),@format)

				------------Print 'tempdbflag = ' + convert(varchar(100),@TempDBFlag)

				------------SELECT LEN(dr.VolumeMountPoint), db.*
				------------	FROM #DBInfo2 db
				------------		JOIN @VolumeSpaces dr ON (dr.databaseid = db.databaseid ) AND
				------------								(dr.fileid = db.fileid )
				------------							WHERE LEN(dr.VolumeMountPoint) >= 3
				------------									--------AND upper(db.DatabaseName) IN ('TEMPDB')
				------------								AND upper(db.DatabaseName) NOT IN
				------------											('MASTER','MODEL','TEMPDB','MSDB')
				-- testing end
--
-- **** new code END **
--


				IF @format = 1 -- Detail only
					BEGIN
						IF @TempDBFlag = 1
							BEGIN
	

								SELECT --@@Servername(),
										db.DatabaseName as DBName,
										db.LogicalFileName as DBLogicalFileName,
										db.PhysicalFileName as DBPhysicalFileName,
										db.RecoveryMode as DBRecoveryMode,
										db.FileSizeMB AS DBFileSizeMB,
										db.FreeSpaceMB as DBFreeSpaceMB,
										db.FreeSpacePct as DBFreeSpacePct,
										CASE growth
											WHEN 0 THEN 0
											ELSE
												CASE maxsize
													WHEN 0 THEN 'No Growth'
										------------WHEN -1 THEN 'File will grow until disk is full'
													WHEN -1 THEN -1
													WHEN 268435456 THEN ' Log file will grow to a maximum size of 2 TB.'
													ELSE (convert(float,db.FileSizeMB) / convert(float,(maxsize/128))*100)
												END
										END as DBMaxsizePct,
										CASE growth
											WHEN 0 THEN 0
											ELSE
												----CASE (statusval)
												----	WHEN 0 THEN
														growth/128
													----ELSE
													----	growth
													----END
											END AS GrowthAmtMBPct,
										CASE (statusval)
											WHEN 0 THEN
												'MB'
											WHEN 1 THEN
												'Percentage' --'MB' fixed 7/24/19
											ELSE
												'Percentage'
										END AS GrowthType,
										CASE
											WHEN LEN(dr.VolumeMountPoint) = 3 THEN LEFT(dr.VolumeMountPoint,1)
											ELSE dr.VolumeMountPoint
											------ELSE dr.Drive
										END AS Drive,
										dr.AvailableMB as DriveFreeSpaceMB,
										dr.TotalMB as DriveTotalSizeMB,
										CAST((dr.AvailableMB/dr.TotalMB) * 100 AS NUMERIC(5,2)) as DriveFreeSpacePct,
										dr.TotalMB * .8 AS DriveMaxUsable,
										CAST((dr.AvailableMB/(dr.TotalMB * .8)) * 100 AS NUMERIC(5,2)) as DriveMaxUsablePct,
										dr.LogicalVolumeName--,
									FROM #DBInfo2 db
										JOIN @VolumeSpaces dr ON (dr.databaseid = db.databaseid ) AND
																(dr.fileid = db.fileid )
								WHERE upper(db.DatabaseName) IN ('TEMPDB')
												----------AND ((convert(decimal(5,2),ISNULL(db.FreeSpacePct,0)) <= @FreeMin)-- OR (convert(decimal(5,2),DBMaxsizePct) >= 80) OR (convert(decimal
												------(5,2),DriveFreeSpacePct) < @FreeMin )) --20.00--20170630
										AND convert(decimal(5,2),ISNULL(db.FreeSpacePct,0)) <= @FreeMin --20.00--20170630
									ORDER BY db.FreeSpacePct ASC, db.DatabaseName ASC;

								END IF @TempDBFlag = 0
-- *****************************************************
-- *                                                   *
-- *                 flag is 0	                       *
--******************************************************
											SELECT --@@Servername(),
													db.DatabaseName,
													db.LogicalFileName,
													db.PhysicalFileName,
													db.RecoveryMode,
													db.FileSizeMB,
													db.FreeSpaceMB as DBFreeSpaceMB,
													db.FreeSpacePct as DBFreeSpacePct,
										CASE growth
											WHEN 0 THEN '0'  -- testing vc
											ELSE
												CASE maxsize
													WHEN 0 THEN 'No Growth'
													WHEN -1 THEN 'File will grow until disk is full'
													----------------WHEN -1 THEN '-1' -- testing as vc
													WHEN 268435456 THEN  ' Log file will grow to a maximum size of 2 TB.'
													ELSE convert(varchar(25),(convert(float,db.FileSizeMB) / convert(float,(maxsize/128))*100))
												END
										END as DBMaxsizePct,
													CASE maxsize  -- testing new code
														WHEN 0 THEN 'No Growth'
														WHEN -1 THEN 'File will grow until disk is full'
														WHEN 268435456 THEN ' Log file will grow to a maximum size of 2 TB.'
														ELSE convert(varchar(128),convert(float,(maxsize/128)) ) + ''
													END as DBMaxsize,
													----------------CASE maxsize  -- testing new code
													----------------	WHEN 0 THEN 'No Growth'
													----------------	WHEN -1 THEN 'File will grow until disk is full'
													----------------	WHEN 268435456 THEN ' Log file will grow to a maximum size of 2 TB.'
													----------------	ELSE convert(varchar(128),((convert (float,db.FileSizeMB)) / convert(float,(maxsize/128))) * 100) + ''
													----------------END as DBMaxsizePct,
										--------------------------CASE growth
										--------------------------	WHEN 0 THEN 0
										--------------------------	ELSE
										--------------------------		----CASE (statusval)
										--------------------------		----	WHEN 0 THEN
										--------------------------				growth/128
										--------------------------			----ELSE
										--------------------------			----	growth
										--------------------------			----END
										--------------------------	END AS GrowthAmtMBPct,
													--------------------CASE maxsize -- testing new code
													--------------------	WHEN 0 THEN 'No Growth'
													--------------------	WHEN -1 THEN 'File will grow until disk is full'
													--------------------	WHEN 268435456 THEN ' Log file will grow to a maximum size of 2 TB.'
													--------------------	ELSE convert(varchar(128),(maxsize/128))
													--------------------END as DBMaxsizeMB,
													CASE (statusval)
														WHEN 0 THEN
															growth/128
														ELSE
															growth/128
													END AS GrowthAmtMBPct,
													statusval, -- testing
													CASE (statusval)
														WHEN 0 THEN
															'MB'
														WHEN 1 THEN
															'Percentage' -- 'MB' fixed 7/24/19
														ELSE
															'Percentage'

															END AS GrowthType,
													CASE
														WHEN LEN(dr.VolumeMountPoint) = 3 THEN LEFT(dr.VolumeMountPoint,1)
														ELSE dr.VolumeMountPoint
													END AS Drive,
													dr.AvailableMB AS DriveFreeSpaceMB, dr.TotalMB as DriveTotalSizeMB,
													--------------------CAST((dr.AvailableMB/dr.TotalMB) * 100 AS NUMERIC(5,2)) as DriveFreeSpacePct,-- was testing
													CAST(dr.DriveFreeSpacePct AS NUMERIC(5,2)) as DriveFreeSpacePct,-- was testing
													dr.TotalMB * .8 AS DriveMaxUsable,
													CAST((dr.AvailableMB/(dr.TotalMB * .8)) * 100 AS NUMERIC(5,2)) as DriveMaxUsablePct, --was testing
													dr.LogicalVolumeName
												FROM #DBInfo2 db
													JOIN @VolumeSpaces dr ON (dr.databaseid = db.databaseid ) AND
																			(dr.fileid = db.fileid )
											WHERE --LEN(dr.VolumeMountPoint) > 3 
													--------AND upper(db.DatabaseName) IN ('TEMPDB')
												--AND 
												upper(db.DatabaseName) NOT IN
															('MASTER','MODEL','TEMPDB','MSDB')
												------------------AND convert(decimal(5,2),ISNULL(db.FreeSpacePct,0)) < @FreeMin --20.00 --20170630 was testing
												AND ((convert(decimal(5,2),ISNULL(db.FreeSpacePct,0)) < @FreeMin) --20.00 --20170630 was testing
												OR (ISNULL(dr.DriveFreeSpacePct,0) < @DiskFreeMin))
											ORDER BY db.DatabaseName ASC, db.FreeSpacePct ASC ;
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
														ELSE convert(varchar(128),(maxsize/128))
												--------ELSE convert(varchar(128),(maxsize/128))+ ' MB'
													END as DBMaxsizeMB,
													CASE (statusval)
														WHEN 0 THEN
															growth/128
														
														------ELSE
														------	growth
													END AS GrowthAmtMBPct,
													CASE (statusval)
														WHEN 0 THEN
															'MB'
														WHEN 1 THEN
															'MB'
														ELSE
															'Percentage'
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
																ELSE ((maxsize/128)/ db.FreeSpaceMB)
															END
													END as MaxSizeFreePct
												FROM #DBInfo2 db
											WHERE db.DatabaseName NOT IN (
													SELECT DatabaseName
														FROM #DBInfo2 DB)
															AND upper(db.DatabaseName) IN ('TEMPDB')
													----------AND upper(db.DatabaseName) NOT IN ('MASTER','MODEL','TEMPDB','MSDB')
										AND convert(decimal(5,2),db.FreeSpacePct) < @FreeMin --20.00--20170630
					--------------------AND db.FreeSpacePct < '20' --20170630
					--------------------AND CAST((dr.[MB free]/dr.[MBTotalSize]) * 100 AS NUMERIC(5,2)) <30 20170630
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
												ELSE convert(varchar(128),(maxsize/128))
											END as DBMaxsizeMB,
											CASE (statusval)
												WHEN 0 THEN
													growth/128
												
												------ELSE
												------	growth
											END AS GrowthAmtMBPct,
											CASE (statusval)
												WHEN 0 THEN
													'MB'
												WHEN 1 THEN
													'MB'
												ELSE
													'Percentage'
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
														ELSE ((maxsize/128)/ db.FreeSpaceMB)
													END
											END as MaxSizeFreePct
										FROM #DBInfo2 db
										----------WHERE upper(db.DatabaseName) NOT IN ('MASTER','MODEL','TEMPDB','MSDB')
									WHERE upper(db.DatabaseName) IN ('TEMPDB')
										AND convert(decimal(5,2),db.FreeSpacePct) < @FreeMin -- 20.00 --20170630
									ORDER BY db.DatabaseName ASC, db.LogicalFileName ASC,db.FreeSpacePct ASC;
							------ORDER BY db.FreeSpacePct ASC, db.DatabaseName ASC;
							END
							----------DROP TABLE #DBInfo2;  --was testing
						END

						DROP TABLE #DBInfo2;  --was testing


					----------IF @putback = 0
					----------	BEGIN
					----------		EXEC sp_configure 'XP_CmdShell', '0';
					----------	----GO
					----------		RECONFIGURE WITH OVERRIDE ;
					----------	----GO
					----------	END
					----------	--GO
END
GO
