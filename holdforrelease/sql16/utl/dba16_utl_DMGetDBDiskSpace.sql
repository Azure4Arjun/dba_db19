SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- ======================================================================================
-- dba16_utl_DMGetDBDiskSpace
--
--
-- Calls:		None
--
-- Description:	Get a listing of the DB disk space for a single DB for all disks that 
--				are part of SQL Server. Requires view system state permisisons.
-- 
-- Date			Modified By			Changes
-- 11/29/2016   Aron E. Tekulsky    Initial Coding.
-- 08/13/2018	Aron E. Tekulsky	Added PctDskUsed, LogicalVolumeName.
-- 08/14/2019	Aron E. Tekulsky	Add filetype, filegroup, new sort order.
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
	SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED

	DECLARE @DbId			int

	DECLARE @VolumeSpaces AS TABLE (
		VolumeMountPoint	nvarchar(512),
		------VolumeId			nvarchar(512),
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
		FileType			tinyint)



	--SELECT @DbId = DB_ID(f.name) FROM sys.database_files AS f;
	------SELECT @DbId = DB_ID(f.name) FROM sys.database_files AS f WHERE file_id = 1;
	SELECT @DbId = ISNULL(DB_ID(f.name),17) FROM sys.database_files AS f WHERE file_id = 1;

	--PRINT 'the id is ' + convert(varchar(25),@DbId)


			
	--SELECT database_id, f.file_id, volume_mount_point, (total_bytes/1024/1024) AS TotalBytesMB, (available_bytes/1024/1024)  AS AvailableBytesMB--, DB_ID(f.name)

	INSERT INTO @VolumeSpaces 
		(VolumeMountPoint,--VolumeId
		LogicalVolumeName, --FileSystemType,
		 TotalMB, AvailableMB, UsedSpace, EightyPercent, MaxUsable, FileId, LogicalName, PhysicalName, DataSpaceId, FileType)
	SELECT vs.volume_mount_point, vs.logical_volume_name, (vs.total_bytes/1024/1024) AS TotalBytesMB, (vs.available_bytes/1024/1024)  AS AvailableBytesMB,
						((vs.total_bytes - vs.available_bytes)/1024/1024 ) AS UsedSpace,
						(vs.total_bytes/1024/1024)*.8 AS EightyPercent,
					CASE 
						WHEN (((vs.total_bytes)*.8) - ((vs.total_bytes - vs.available_bytes))) > 0 THEN
							(((vs.total_bytes)*.8) - ((vs.total_bytes - vs.available_bytes))) /1024/1024 
						ELSE 0
					END AS MaxUsable,
	  f.file_id--, DB_ID(f.name)
	 ,f.name, Physical_Name, f.data_space_id, f.type 
		FROM sys.database_files AS f  
			CROSS APPLY sys.dm_os_volume_stats(@DbId, f.file_id) AS vs;

	SELECT DB_name (@DbId) AS DbName, s.FileId, s.LogicalName, ISNULL(g.name,'N/A') AS FileGroup , s.VolumeMountPoint AS Path, s.PhysicalName , s.TotalMB , s.AvailableMB , s.UsedSpace AS UsedSpaceMB , s.EightyPercent AS EightyPercentMB , 
			s.MaxUsable AS MaxUsableMB, CONVERT(decimal(20,4),(CONVERT(decimal(20,4),s.UsedSpace) / (CONVERT(decimal(20,4),s.TotalMB))*100)) AS PctDskUsed, s.LogicalVolumeName--, s.DataSpaceId  
			------s.MaxUsable, CONVERT(decimal(20,4),(CONVERT(decimal(20,4),s.UsedSpace) / (CONVERT(decimal(20,4),s.EightyPercent))*100)) AS PctDskUsed, s.LogicalVolumeName--, s.DataSpaceId  
		FROM @VolumeSpaces s
			LEFT JOIN sys.filegroups g ON (g.data_space_id = s.DataSpaceId )
	------WHERE s.MaxUsable > 0
	ORDER BY s.FileType , FileGroup ASC ,s.FileId ASC; --s.LogicalName ASC;
END
GO
