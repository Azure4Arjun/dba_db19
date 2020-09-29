SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- ======================================================================================
-- dba19_tbl_GetListAllObjectsnIndexesperFilegroupBA
--
--
-- Calls:		None
--
-- Description:	List all Objects and Indexes per Filegroup / Partition.
--
-- https://basitaalishan.com/2013/03/03/list-all-objects-and-indexes-per-filegroup-partition/
-- 
-- Date			Modified By			Changes
-- 07/29/2019   Aron E. Tekulsky    Initial Coding.
-- 07/29/2019   Aron E. Tekulsky    Update to Version 140.
-- 07/30/2019	Aron E. Tekulsky	Add mount points that items are on.
-- 08/15/2019	Aron E. Tekulsky	Add file group to sort.
-- 07/15/2020	Aron E. Tekulsky	Add % for used and available.
-- 08/26/2020   Aron E. Tekulsky    Update to Version 150.
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

	DECLARE @Cmd				NVARCHAR(4000)
	DECLARE @DBId				int	-- testing
	DECLARE @DBName				NVARCHAR(128)
	DECLARE @DBNametoFind		NVARCHAR(128)

	DECLARE @ObjectsnPartitions TABLE (
			ServerName			nvarchar(128),
			DBName				nvarchar(128),
			ObjectName			nvarchar(128),
			IndexID				int,
			IndexName			nvarchar(128),
			----IndexType			tinyint,	-- 0 = Heap, 1 = Clustered, 2 = Nonclustered, 3 = XML, 4 = Spatial, 5 = Clustered columnstore index. Applies to: SQL Server 2014 (12.x) through SQL Server 2017.
			IndexType			nvarchar(128),	-- 0 = Heap, 1 = Clustered, 2 = Nonclustered, 3 = XML, 4 = Spatial, 5 = Clustered columnstore index. Applies to: SQL Server 2014 (12.x) through SQL Server 2017.
										-- 6 = Nonclustered columnstore index. Applies to: SQL Server 2012 (11.x) through SQL Server 2017.
										-- 7 = Nonclustered hash index. Applies to: SQL Server 2014 (12.x) through SQL Server 2017.
			PartitionSchema		nvarchar(128),
			FileGroup			nvarchar(128),
			DatabaseSpaceID		int,
			DatabaseFileName	nvarchar(260),
			DatabaseId			int,				-- testing
			FileId				int
				)

--  ********************************
--          testing new code       *
--  ********************************

	DECLARE @VolumeSpaces AS TABLE (
		VolumeMountPoint		nvarchar(512), -- disk
		----VolumeId			nvarchar(512),
		LogicalVolumeName		nvarchar(512),
		FileSystemType			nvarchar(512),
		TotalMB					float, -- total
		AvailableMB				float, -- free
		UsedSpace				float, -- used 
		EightyPercent			float,
		MaxUsable				float,
		databaseid				int,
		fileid					int)

-- get the volume mount points.

	INSERT INTO @VolumeSpaces 
		(VolumeMountPoint,--VolumeId,
		LogicalVolumeName,FileSystemType, TotalMB, AvailableMB, UsedSpace, EightyPercent, MaxUsable,
						databaseid,fileid)
	SELECT DISTINCT vs.volume_mount_point AS [Drive],
					----vs.volume_id ,
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
					END AS MaxUsable,
					f.database_id , f.file_id
		FROM sys.master_files AS f
			CROSS APPLY sys.dm_os_volume_stats(f.database_id, f.file_id) AS vs
	WHERE f.type = 0
	ORDER BY vs.volume_mount_point;

	------SELECT 'mount points ', *
	------	FROM @VolumeSpaces;

--  ********************************
--      End testing new code       *
--  ********************************

-- The following two queries return information about 
-- which objects belongs to which filegroup
	-- set the name of the db to find
	----SET @DBNametoFind = 'dba_db16';

	SET @DBNametoFind = 'test6';

	----SET @DBNametoFind = '';
	IF @DBNametoFind IS NULL
		OR @DBNametoFind = ''
		BEGIN
			DECLARE db_cur CURSOR
				FOR
					SELECT d.name, d.database_id
						FROM sys.databases d
					WHERE d.database_id > 4;
		END
	ELSE
		BEGIN
			DECLARE db_cur CURSOR
				FOR
					SELECT d.name, d.database_id
						FROM sys.databases d
					WHERE d.database_id > 4
						AND d.name = @DBNametoFind;
		END

	OPEN db_cur;

	FETCH NEXT
		FROM db_cur
			INTO @DBName, @DBId;

	WHILE (@@FETCH_STATUS = 0)
		BEGIN
			SET @CMD = 'USE [' + @DBName + '] ' +
			 
				' SELECT ' + '''' + @@ServerName + '''' + ', ' + '''' + @DBName + '''' + ', ' + 
						'OBJECT_NAME(i.[object_id]) AS [ObjectName]
						,i.[index_id] AS [IndexID]
						,i.[name] AS [IndexName]
						,i.[type_desc] AS [IndexType]
						,pf.name AS [Partition Schema]
						,f.[name] AS [FileGroup]
						,i.[data_space_id] AS [DatabaseSpaceID]
						,d.[physical_name] AS [DatabaseFileName]
						, ' + '''' +  CONVERT(nvarchar(10),@DBId) + '''' + '
						, d.file_id
					FROM [sys].[indexes] i
						LEFT JOIN SYS.partition_schemes pf ON pf.[data_space_id] = i.[data_space_id]
						INNER JOIN [sys].[filegroups] f ON f.[data_space_id] = i.[data_space_id]
						------INNER JOIN [sys].[database_files] d ON f.[data_space_id] = d.[data_space_id]
						LEFT JOIN [sys].[database_files] d ON f.[data_space_id] = d.[data_space_id]
						INNER JOIN [sys].[data_spaces] s ON f.[data_space_id] = s.[data_space_id]
				WHERE OBJECTPROPERTY(i.[object_id], ' + '''' + 'IsUserTable' + '''' + ') = 1
				ORDER BY OBJECT_NAME(i.[object_id]) ASC, f.[name] ASC;'
				------ORDER BY OBJECT_NAME(i.[object_id]) ASC, m.[name] ASC, i.[data_space_id] ASC;'


				PRINT @CMD;

				INSERT INTO @ObjectsnPartitions
						( ServerName,
						DBName, 
						ObjectName, 
						IndexID, 
						IndexName, 
						IndexType, 
						PartitionSchema, 
						FileGroup, 
						DatabaseSpaceID, 
						DatabaseFileName,
						DatabaseId,
						FileId)
					EXEC (@CMD);

		FETCH NEXT
		FROM db_cur
			INTO @DBName, @DBId;

	END

	CLOSE db_cur;

	DEALLOCATE db_cur;

	SELECT o.ServerName, o.DBName, o.FileGroup, o.ObjectName, o.IndexID, o.IndexName, o.IndexType, o.PartitionSchema, o.DatabaseSpaceID, o.DatabaseFileName
				,v.LogicalVolumeName , v.TotalMB , v.UsedSpace 
				, CONVERT(decimal(20,2), (v.AvailableMB / v.TotalMB) *100) AS [%Used]
				, v.AvailableMB , CONVERT(decimal(20,2), (v.AvailableMB / v.TotalMB) * 100) AS [%Available]
				,v.MaxUsable , v.EightyPercent 
		FROM @ObjectsnPartitions o
				INNER JOIN @VolumeSpaces v ON (v.databaseid = o.DatabaseId ) AND
												(v.fileid = o.FileId )
	ORDER BY ServerName ASC, DBName ASC, --o.FileGroup ASC, 
				ObjectName ASC, IndexID ASC, DatabaseSpaceID ASC;

END
GO
