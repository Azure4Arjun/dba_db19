SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- ======================================================================================
-- dba16_utl_DMGetDiskSpace
--
--
-- Calls:		None
--
-- Description:	Get a listing of the disk space for all disks that are part 
--				of SQL Server. Requires view system state permisisons.
-- 
-- Date			Modified By			Changes
-- 11/28/2016   Aron E. Tekulsky    Initial Coding.
-- 08/13/2018	Aron E. Tekulsky	Added PctDskUsed, LogicalVolumeName.
-- 08/14/2019	Aron E. Tekulsky	Add filetype, filegroup, new sort order.
-- 11/07/2019	Aron E. Tekulsky	Add db name, summary to get statistics.
-- 11/18/2019	Aron E. Tekulsky	amm more statistice by MP and list MP.
-- 12/04/2019	Aron E. Tekulsky	ad db file statistics.
--	12/20/2019	Aron E. Tekulsky	add uised db.
-- note so i need to not sum up disk storage becaus tht makes it multplied when it shoudl be single value nly ?
-- ======================================================================================
--	Copyright©2001 - 2025 Aron Tekulsky.  World wide rights reserved.
--	Use of this code is free of charge but does not in any way imply transfer of 
--	Copyright ownership to the user.
-- ======================================================================================
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	DECLARE @Cmd			nvarchar(4000)

	DECLARE @VolumeSpaces AS TABLE (
		VolumeMountPoint	nvarchar(512),
		VolumeId			nvarchar(512),
		LogicalVolumeName	nvarchar(512),
		FileSystemType		nvarchar(512),
		TotalMB				bigint,
		AvailableMB			bigint,
		UsedSpace			bigint,
		EightyPercent		bigint,
		MaxUsable			bigint,
		------DatabaseId			int,
		FileId				int,
		LogicalName			nvarchar(128),
		PhysicalName		nvarchar(260),
		DataSpaceId			int,
		FileType			tinyint,
		Databasename		nvarchar(128),
		DBStateDesc			nvarchar(60),
		DBSizeMb			int,
		DbMaxSizeMb			varchar(128),
		DbAutoGrowth		varchar(128),
		DbGrowthMbPct		varchar(128))

	------DECLARE @VolumeSpacesSummary AS TABLE (
	------	Databasename		nvarchar(128),
	------	FileType			tinyint,
	------	VolumeCount			int,
	------	TotalMB				bigint,
	------	AvailableMB			bigint,
	------	UsedSpace			bigint,
	------	MaxUsable			bigint)

	DECLARE @DbSpace AS TABLE (
		Databasename		nvarchar(128),
		FileId				int,
		TypeFile			tinyint,
		DataSpaceId			int,
		LogicalName			nvarchar(128),
		FileState			tinyint,
		CurrentlyAllocated	decimal(20,2),
		AvailableSpace		decimal(20,2),
		Used				decimal(20,2)
	)

	-- get deetails.
	INSERT INTO @VolumeSpaces 
		(VolumeMountPoint,VolumeId,LogicalVolumeName,FileSystemType, TotalMB, AvailableMB, UsedSpace, EightyPercent, MaxUsable
			, FileId, LogicalName, PhysicalName, DataSpaceId, FileType, Databasename
			,DBStateDesc, DBSizeMb, DbMaxSizeMb, DbAutoGrowth, DbGrowthMbPct)
	SELECT DISTINCT vs.volume_mount_point AS [Drive],
					vs.volume_id ,
					vs.logical_volume_name AS [Drive Name],
					vs.file_system_type ,
					vs.total_bytes/1024/1024 AS [Drive Size MB],
					vs.available_bytes/1024/1024 AS [Drive Free Space MB],
					((vs.total_bytes - vs.available_bytes)/1024/1024 ) AS UsedSpace,
					(vs.total_bytes/1024/1024)*.8 AS EightyPercent,
					CASE 
						WHEN (((vs.total_bytes)*.8) - ((vs.total_bytes - vs.available_bytes))) > 0 THEN
							(((vs.total_bytes)*.8) - ((vs.total_bytes - vs.available_bytes))) /1024/1024 
						ELSE 0
					END AS MaxUsable
					, f.file_id,f.name, Physical_Name, f.data_space_id, f.type
					,d.name
					,f.state_desc 
					,f.size / 128 as [sizemb]
					,CASE f.max_size
						WHEN 0 THEN
							'No growth Allowed'
						WHEN -1 THEN
							CASE f.growth
								WHEN 0 THEN	
									'None'
								ELSE
									'File will grow until disk is full'
								END
						ELSE
							CONVERT(varchar(128), f.max_size/128)
						END AS max_sizemb
					,CASE f.growth
						WHEN 0 THEN
							'None'
						ELSE
							CASE f.is_percent_growth
								WHEN 0 THEN
									CONVERT(varchar(128), f.growth/128)
								ELSE
									CONVERT(varchar(128), f.growth/128)
								END
						END AS Autogrowth
					,CASE f.is_percent_growth
						WHEN 0 THEN
							'MB'
						ELSE
							'%'
						END  AS [Growth(mb/%)]
		FROM sys.master_files AS f
			CROSS APPLY sys.dm_os_volume_stats(f.database_id, f.file_id) AS vs
			JOIN sys.databases d ON (d.database_id = f.database_id )
	ORDER BY d.name, f.file_id ASC;


	SET @Cmd = 
			' USE [?] ' +
		' SELECT ' + '''' + '?' + '''' + ' ,d.file_id , d.type , d.data_space_id , d.name,d.state , 
				d.size/128.0 AS Size,
				CONVERT(decimal(20,4),d.size/128.0 - CAST(FILEPROPERTY(d.name, ' + '''' + 'SpaceUsed' + '''' + ') AS int)/128.0) AS Available,
				CONVERT(decimal(20,4),CAST(FILEPROPERTY(d.name, ' + '''' + 'SpaceUsed' + '''' + ') AS int)/128.0) AS Ued
			FROM sys.database_files d;';

	PRINT @Cmd;

	INSERT INTO @DbSpace
		(Databasename, FileId, TypeFile, DataSpaceId, LogicalName, FileState, CurrentlyAllocated, AvailableSpace, Used)
	EXEC SP_MSFOREACHDB @Cmd;


	-- get stats
		------INSERT INTO @VolumeSpacesSummary 
		------	(Databasename, FileType, VolumeCount, TotalMB, AvailableMB, UsedSpace, MaxUsable)
		------SELECT v.Databasename, v.FileType, COUNT(v.PhysicalName), SUM(v.TotalMB),
		------		SUM(v.AvailableMB), SUM(v.UsedSpace), SUM(v.MaxUsable)
		------	FROM @VolumeSpaces v
		------GROUP BY v.Databasename, v.FileType
		------ORDER BY v.Databasename, v.FileType ASC;

	SELECT'By DB' AS RPT, @@servername AS ServerNames, s.databaseName, 
			s.FileId, s.LogicalName, ISNULL(g.name,'N/A') AS FileGroup , s.VolumeMountPoint AS Path,--s.VolumeId, 
			s.PhysicalName,s.LogicalVolumeName,--s.FileSystemType, 
			s.TotalMB AS DTotMB, s.AvailableMB AS DAvailMB, 
			s.UsedSpace AS DUsedMB, s.EightyPercent AS Pct80MB, s.MaxUsable AS MaxUsableMB, 
			CONVERT(decimal(20,4),(CONVERT(decimal(20,4),s.UsedSpace) / (CONVERT(decimal(20,4),s.EightyPercent))*100)) AS PctDskUsed
			,s.DBStateDesc , s.DBSizeMb , s.DbMaxSizeMb , s.DbAutoGrowth, s.DbGrowthMbPct  
			,d.CurrentlyAllocated AS DBCurrentlyAllocatedMB, d.Used  AS UsedMB,  s.AvailableMB  AS DBAvailableSpaceMB,
			CASE d.CurrentlyAllocated
				WHEN 0 THEN
					0
				ELSE
					CONVERT(decimal(20,4), (d.Used / d.CurrentlyAllocated) *100) 
			END AS PctDBUsed
		FROM @VolumeSpaces s
			LEFT JOIN sys.filegroups g ON (g.data_space_id = s.DataSpaceId )
			LEFT JOIN @DbSpace d ON (d.Databasename = s.Databasename )
								AND (d.FileId = s.FileId )
	ORDER BY  ServerNames ASC,s.Databasename, s.FileId ASC; 

	SELECT'By MP' AS RPT, @@servername AS ServerNames, s.databaseName, 
			s.FileId, s.LogicalName, ISNULL(g.name,'N/A') AS FileGroup , s.VolumeMountPoint AS Path,--s.VolumeId, 
			s.PhysicalName,s.LogicalVolumeName,--s.FileSystemType, 
			s.TotalMB AS DTotMB, s.AvailableMB AS DAvailMB, 
			s.UsedSpace AS DUsedMB, s.EightyPercent AS Pct80MB, s.MaxUsable AS MaxUsableMB, 
			CONVERT(decimal(20,4),(CONVERT(decimal(20,4),s.UsedSpace) / (CONVERT(decimal(20,4),s.EightyPercent))*100)) AS PctDskUsed
			,s.DBStateDesc , s.DBSizeMb , s.DbMaxSizeMb , s.DbAutoGrowth, s.DbGrowthMbPct  
			,d.CurrentlyAllocated AS DBCurrentlyAllocatedMB, d.Used  AS UsedMB, s.AvailableMB  AS DBAvailableSpaceMB,
			CASE d.CurrentlyAllocated
				WHEN 0 THEN
					0
				ELSE
					CONVERT(decimal(20,4), (d.Used / d.CurrentlyAllocated) *100) 
			END AS PctDBUsed
		FROM @VolumeSpaces s
			LEFT JOIN sys.filegroups g ON (g.data_space_id = s.DataSpaceId )
			LEFT JOIN @DbSpace d ON (d.Databasename = s.Databasename )
								AND (d.FileId = s.FileId )
	ORDER BY  ServerNames ASC,s.VolumeMountPoint ASC, s.Databasename, s.FileId ASC; 

	-- get stats

	SELECT'Statistics By DB' AS RPT,s.databaseName, 
			CASE s.FileType 
				WHEN 0 THEN 'Data'
				ELSE 'Log'
			END as FileType
			,COUNT(s.PhysicalName) as VolumeCount,SUM(s.TotalMB) /COUNT(s.PhysicalName) AS TOTALMB, 
			SUM(s.AvailableMB)/COUNT(s.PhysicalName) AS DAvailMB, 
			SUM(s.UsedSpace) /COUNT(s.PhysicalName) AS DUsedMB, SUM(s.MaxUsable) / COUNT(s.PhysicalName) AS MaxUsableMB, 
			SUM(s.DBSizeMb) AS DBSizeMbDB,   
			SUM(d.CurrentlyAllocated) AS DBCurrentlyAllocatedMB, SUM(d.Used)  AS UsedMB, SUM(s.AvailableMB)  AS DBAvailableSpaceMB,
			CASE SUM(d.CurrentlyAllocated)
				WHEN 0 THEN
					0
				ELSE
					CONVERT(decimal(20,4), (SUM(d.Used) / SUM(d.CurrentlyAllocated)) *100) 
			END AS PctDBUsed
		FROM @VolumeSpaces s
			----LEFT JOIN sys.filegroups g ON (g.data_space_id = s.DataSpaceId )
			LEFT JOIN @DbSpace d ON (d.Databasename = s.Databasename )
								AND (d.FileId = s.FileId )
	GROUP BY s.databaseName, s.FileType
	ORDER BY  s.Databasename, s.FileType ASC;

	SELECT'Statistics By DB Data' AS RPT,s.databaseName, 
			CASE s.FileType 
				WHEN 0 THEN 'Data'
				ELSE 'Log'
			END as FileType
			,COUNT(s.PhysicalName) as VolumeCount,SUM(s.TotalMB) /COUNT(s.PhysicalName) AS TOTALMB, 
			SUM(s.AvailableMB)/COUNT(s.PhysicalName) AS DAvailMB, 
			SUM(s.UsedSpace) /COUNT(s.PhysicalName) AS DUsedMB, SUM(s.MaxUsable) / COUNT(s.PhysicalName) AS MaxUsableMB, 
			SUM(s.DBSizeMb) AS DBSizeMbDB,   
			SUM(d.CurrentlyAllocated) AS DBCurrentlyAllocatedMB, SUM(d.Used)  AS UsedMB, SUM(s.AvailableMB)  AS DBAvailableSpaceMB,
			CASE SUM(d.CurrentlyAllocated)
				WHEN 0 THEN
					0
				ELSE
					CONVERT(decimal(20,4), (SUM(d.Used) / SUM(d.CurrentlyAllocated)) *100) 
			END AS PctDBUsed
		FROM @VolumeSpaces s
			----LEFT JOIN sys.filegroups g ON (g.data_space_id = s.DataSpaceId )
			LEFT JOIN @DbSpace d ON (d.Databasename = s.Databasename )
								AND (d.FileId = s.FileId )
	WHERE s.filetype = 0
		AND db_id(s.databasename) > 4
	GROUP BY s.databaseName, s.FileType
	ORDER BY  s.Databasename, s.FileType ASC;

	
	SELECT'Statistics By DB Log' AS RPT,s.databaseName, 
			CASE s.FileType 
				WHEN 0 THEN 'Data'
				ELSE 'Log'
			END as FileType
			,COUNT(s.PhysicalName) as VolumeCount,SUM(s.TotalMB) /COUNT(s.PhysicalName) AS TOTALMB, 
			SUM(s.AvailableMB)/COUNT(s.PhysicalName) AS DAvailMB, 
			SUM(s.UsedSpace) /COUNT(s.PhysicalName) AS DUsedMB, SUM(s.MaxUsable) / COUNT(s.PhysicalName) AS MaxUsableMB, 
			SUM(s.DBSizeMb) AS DBSizeMbDB,   
			SUM(d.CurrentlyAllocated) AS DBCurrentlyAllocatedMB, SUM(d.Used)  AS UsedMB, SUM(s.AvailableMB)  AS DBAvailableSpaceMB,
			CASE SUM(d.CurrentlyAllocated)
				WHEN 0 THEN
					0
				ELSE
					CONVERT(decimal(20,4), (SUM(d.Used) / SUM(d.CurrentlyAllocated)) *100) 
			END AS PctDBUsed
		FROM @VolumeSpaces s
			----LEFT JOIN sys.filegroups g ON (g.data_space_id = s.DataSpaceId )
			LEFT JOIN @DbSpace d ON (d.Databasename = s.Databasename )
								AND (d.FileId = s.FileId )
	WHERE s.filetype = 1
		AND db_id(s.databasename) > 4
	GROUP BY s.databaseName, s.FileType
	ORDER BY  s.Databasename, s.FileType ASC;

	
	SELECT'Statistics By MPFT' AS RPT,s.VolumeMountPoint , COUNT(s.databasename),
			CASE s.FileType 
				WHEN 0 THEN 'Data'
				ELSE 'Log'
			END as FileType
			,COUNT(s.PhysicalName) as VolumeCount,SUM(s.TotalMB) /COUNT(s.PhysicalName) AS TOTALMB, 
			SUM(s.AvailableMB)/COUNT(s.PhysicalName) AS DAvailMB, 
			SUM(s.UsedSpace) /COUNT(s.PhysicalName) AS DUsedMB, SUM(s.MaxUsable) / COUNT(s.PhysicalName) AS MaxUsableMB, 
			SUM(s.DBSizeMb) AS DBSizeMbDB,   
			SUM(d.CurrentlyAllocated) AS DBCurrentlyAllocatedMB, SUM(d.Used)  AS UsedMB, SUM(s.AvailableMB)  AS DBAvailableSpaceMB,
			CASE SUM(d.CurrentlyAllocated)
				WHEN 0 THEN
					0
				ELSE
					CONVERT(decimal(20,4), (SUM(d.Used) / SUM(d.CurrentlyAllocated)) *100) 
			END AS PctDBUsed
		FROM @VolumeSpaces s
			----LEFT JOIN sys.filegroups g ON (g.data_space_id = s.DataSpaceId )
			LEFT JOIN @DbSpace d ON (d.Databasename = s.Databasename )
								AND (d.FileId = s.FileId )
	WHERE db_id(s.databasename) > 4
	GROUP BY s.VolumeMountPoint , s.FileType 
	ORDER BY  s.VolumeMountPoint , s.FileType ASC;

	SELECT'Statistics By MP Log' AS RPT,s.VolumeMountPoint  ,COUNT(s.databaseName), 
			CASE s.FileType 
				WHEN 0 THEN 'Data'
				ELSE 'Log'
			END as FileType
			,COUNT(s.PhysicalName) as VolumeCount,SUM(s.TotalMB) /COUNT(s.PhysicalName) AS TOTALMB, 
			SUM(s.AvailableMB)/COUNT(s.PhysicalName) AS DAvailMB, 
			SUM(s.UsedSpace) /COUNT(s.PhysicalName) AS DUsedMB, SUM(s.MaxUsable) / COUNT(s.PhysicalName) AS MaxUsableMB, 
			SUM(s.DBSizeMb) AS DBSizeMbDB,   
			SUM(d.CurrentlyAllocated) AS DBCurrentlyAllocatedMB, SUM(d.Used)  AS UsedMB, SUM(s.AvailableMB)  AS DBAvailableSpaceMB,
			CASE SUM(d.CurrentlyAllocated)
				WHEN 0 THEN
					0
				ELSE
					CONVERT(decimal(20,4), (SUM(d.Used) / SUM(d.CurrentlyAllocated)) *100) 
			END AS PctDBUsed
		FROM @VolumeSpaces s
			----LEFT JOIN sys.filegroups g ON (g.data_space_id = s.DataSpaceId )
			LEFT JOIN @DbSpace d ON (d.Databasename = s.Databasename )
								AND (d.FileId = s.FileId )
	WHERE s.filetype = 1
		AND db_id(s.databasename) > 4
	GROUP BY s.VolumeMountPoint , s.FileType 
	ORDER BY  s.VolumeMountPoint , s.FileType ASC;

		SELECT'Statistics By MP Data' AS RPT,s.VolumeMountPoint  ,COUNT(s.databaseName), 
			CASE s.FileType 
				WHEN 0 THEN 'Data'
				ELSE 'Log'
			END as FileType
			,COUNT(s.PhysicalName) as VolumeCount,SUM(s.TotalMB) /COUNT(s.PhysicalName) AS TOTALMB, 
			SUM(s.AvailableMB)/COUNT(s.PhysicalName) AS DAvailMB, 
			SUM(s.UsedSpace) /COUNT(s.PhysicalName) AS DUsedMB, SUM(s.MaxUsable) / COUNT(s.PhysicalName) AS MaxUsableMB, 
			SUM(s.DBSizeMb) AS DBSizeMbDB,   
			SUM(d.CurrentlyAllocated) AS DBCurrentlyAllocatedMB, SUM(d.Used)  AS UsedMB, SUM(s.AvailableMB)  AS DBAvailableSpaceMB,
			CASE SUM(d.CurrentlyAllocated)
				WHEN 0 THEN
					0
				ELSE
					CONVERT(decimal(20,4), (SUM(d.Used) / SUM(d.CurrentlyAllocated)) *100) 
			END AS PctDBUsed
		FROM @VolumeSpaces s
			----LEFT JOIN sys.filegroups g ON (g.data_space_id = s.DataSpaceId )
			LEFT JOIN @DbSpace d ON (d.Databasename = s.Databasename )
								AND (d.FileId = s.FileId )
	WHERE s.filetype = 0
		AND db_id(s.databasename) > 4
	GROUP BY s.VolumeMountPoint , s.FileType 
	ORDER BY  s.VolumeMountPoint , s.FileType ASC;

	------SELECT @@servername AS ServerNames,vs.Databasename, 
	------	CASE vs.FileType
	------		WHEN 0 THEN 'Data'
	------		ELSE 'Log'
	------	END AS FileType,
	------	vs.VolumeCount , vs.TotalMB , vs.AvailableMB , vs.UsedSpace , vs.MaxUsable 
	------		FROM @VolumeSpacesSummary vs
	------ORDER BY vs.Databasename ASC, vs.FileType  ASC;

END
GO
