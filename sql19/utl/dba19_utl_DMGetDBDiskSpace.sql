SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- ======================================================================================
-- dba19_utl_DMGetDBDiskSpace
--
--
-- Calls:		None
--
-- Description:	Get a listing of the DB disk space for a single DB for all disks that 
--				are part of SQL Server. Requires view system state permissions.
-- 
-- Date			Modified By			Changes
-- 11/29/2016   Aron E. Tekulsky    Initial Coding.
-- 08/13/2018	Aron E. Tekulsky	Added PctDskUsed, LogicalVolumeName.
-- 08/14/2019	Aron E. Tekulsky	Add filetype, filegroup, new sort order.
-- 08/26/2020   Aron E. Tekulsky    Update to Version 150.
-- 09/29/2020	Aron E. Tekulsky	Update column headers.
--									Add ability to get summaries.
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

	DECLARE @DbId			int
	DECLARE @ReportType		int

	DECLARE @VolumeSpaces AS TABLE (
		DBId				int,
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


	SET @ReportType = 0; -- 0 all, 1 detail only, 2 summary only.

	--SELECT @DbId = DB_ID(f.name) FROM sys.database_files AS f;
	------SELECT @DbId = DB_ID(f.name) FROM sys.database_files AS f WHERE file_id = 1;
	SELECT @DbId = ISNULL(DB_ID(f.name),17) FROM sys.database_files AS f WHERE file_id = 1;

	--PRINT 'the id is ' + convert(varchar(25),@DbId)


			
	--SELECT database_id, f.file_id, volume_mount_point, (total_bytes/1024/1024) AS TotalBytesMB, (available_bytes/1024/1024)  AS AvailableBytesMB--, DB_ID(f.name)

	INSERT INTO @VolumeSpaces 
		(DBId, VolumeMountPoint,--VolumeId
		LogicalVolumeName, --FileSystemType,
		 TotalMB, AvailableMB, UsedSpace, EightyPercent, MaxUsable, FileId, LogicalName, PhysicalName, DataSpaceId, FileType)
	SELECT @DbId, vs.volume_mount_point, vs.logical_volume_name, (vs.total_bytes/1024/1024) AS TotalBytesMB, (vs.available_bytes/1024/1024)  AS AvailableBytesMB,
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

	IF @ReportType < 2
		SELECT DB_name (DBId) AS DbName, s.FileId, s.LogicalName, ISNULL(g.name,'N/A') AS FileGroup ,
				s.VolumeMountPoint AS Path, s.PhysicalName , s.TotalMB  AS [TotalDSK(MB)], 
				s.AvailableMB AS [AvailableDsk(MB)] , s.UsedSpace AS [UsedSpaceDsk(MB)] , 
				s.EightyPercent AS [EightyPercentDsk(MB)] , 
				s.MaxUsable AS [MaxUsableDsk(MB)], 
				CONVERT(decimal(20,4),(CONVERT(decimal(20,4),s.UsedSpace) / (CONVERT(decimal(20,4),s.TotalMB))*100)) AS PctDskUsed,
				s.LogicalVolumeName--, s.DataSpaceId  
				------s.MaxUsable, CONVERT(decimal(20,4),(CONVERT(decimal(20,4),s.UsedSpace) / (CONVERT(decimal(20,4),s.EightyPercent))*100)) AS PctDskUsed, s.LogicalVolumeName--, s.DataSpaceId  
			FROM @VolumeSpaces s
				LEFT JOIN sys.filegroups g ON (g.data_space_id = s.DataSpaceId )
		------WHERE s.MaxUsable > 0
		ORDER BY s.FileType , FileGroup ASC ,s.FileId ASC; --s.LogicalName ASC;

	IF @ReportType <> 1
		SELECT DB_name (DBId) AS DbName,  ISNULL(g.name,'N/A') AS FileGroup ,
				SUM(s.TotalMB)  AS [TotalDSK(MB)], 
				SUM(s.AvailableMB) AS [AvailableDsk(MB)] , SUM(s.UsedSpace) AS [UsedSpaceDsk(MB)] , 
				SUM(s.EightyPercent) AS [EightyPercentDsk(MB)] , 
				SUM(s.MaxUsable) AS [MaxUsableDsk(MB)], 
				CONVERT(decimal(20,4),(CONVERT(decimal(20,4),SUM(s.UsedSpace)) / (CONVERT(decimal(20,4),SUM(s.TotalMB)))*100)) AS PctDskUsed	 
			FROM @VolumeSpaces s
				LEFT JOIN sys.filegroups g ON (g.data_space_id = s.DataSpaceId )
		GROUP BY DB_name (DBId), ISNULL(g.name,'N/A')
		ORDER BY  FileGroup ASC ; --s.LogicalName ASC;
		----ORDER BY s.FileType , FileGroup ASC ,s.FileId ASC; --s.LogicalName ASC;

END
GO
