SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- ======================================================================================
-- p_dba19_sys_DMGetDBDiskSpaceByLogicalName
--
-- Arguments:	@DbLogicalName	nvarchar(128)
--				@DbName			nvarchar(128)
--				@MaxUsable		bigint	OUTPUT
--
-- CallS:		None
--
-- Called BY:	p_dba14_alt_Set1105Error
--				p_dba14_GetDBFileAllocationExpansion
--
-- Description:	Get a listing of the DB disk space for all disks that are part
--				of SQL Server. get their space left available to be used to 
--				expand filegroups for the database.Requires view system state 
--				permisisons.
-- 
-- Date			Modified By			Changes
-- 11/29/2016   Aron E. Tekulsky    Initial Coding.
-- 02/17/2018   Aron E. Tekulsky    Update to Version 140.
-- 05/26/2020   Aron E. Tekulsky    Update to Version 150.
-- ======================================================================================
--	Copyright©2001 - 2025 Aron Tekulsky.  World wide rights reserved.
--	Use of this code is free of charge but does not in any way imply transfer of 
--	Copyright ownership to the user.
-- ======================================================================================
--
CREATE PROCEDURE p_dba19_sys_DMGetDBDiskSpaceByLogicalName 
	-- Add the parameters for the stored procedure here
	@DbLogicalName	nvarchar(128), 
	@DbName			nvarchar(128),
	@MaxUsable		bigint	OUTPUT
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;

	DECLARE @Cmd				nvarchar(4000)
	DECLARE @DbId				int
	DECLARE @MaxUsableReturn	bigint

	DECLARE @VolumeSpaces AS TABLE (
		VolumeMountPoint		nvarchar(512),
		VolumeId				nvarchar(512),
		LogicalVolumeName		nvarchar(512),
		FileSystemType			nvarchar(512),
		TotalMB					bigint,
		AvailableMB				bigint,
		UsedSpace				bigint,
		EightyPercent			bigint,
		MaxUsable				bigint,
		DatabaseId				int,
		FileId					int,
		LogicalName				nvarchar(128))

	-- get the databse id
	SET @DbId = DB_ID (@DbName);

	-- set up dynamic query
	SET @Cmd = 'USE [' + @DbName + '] ' + CHAR(10)  + 
		'SELECT vs.volume_mount_point, (vs.total_bytes/1024/1024) AS TotalBytesMB, (vs.available_bytes/1024/1024)  AS AvailableBytesMB,
			((vs.total_bytes - vs.available_bytes)/1024/1024 ) AS UsedSpace,
			(vs.total_bytes/1024/1024)*.8 AS EightyPercent,
			CASE 
				WHEN (((vs.total_bytes)*.8) - ((vs.total_bytes - vs.available_bytes))) > 0 THEN
					(((vs.total_bytes)*.8) - ((vs.total_bytes - vs.available_bytes))) /1024/1024 
				ELSE 0
			END AS MaxUsable, ' + 
			CONVERT(varchar(20),@DbId) + ', f.file_id ,f.name
		FROM [' + @DbName + '].sys.database_files AS f  
			CROSS APPLY sys.dm_os_volume_stats(' + CONVERT(nvarchar(20),@DbId) + ', f.file_id) AS vs;
'
	PRINT @Cmd

	INSERT INTO @VolumeSpaces 
		(VolumeMountPoint,--VolumeId,--LogicalVolumeName,FileSystemType,
		TotalMB, AvailableMB, UsedSpace, EightyPercent, MaxUsable, DatabaseId, FileId, LogicalName)
	 EXEC (@Cmd);
	
	---------- --testing
	----------SELECT'vs ',  *
	----------	FROM @VolumeSpaces;
	---------- --end testing

	-- set up the return values
	SELECT @MaxUsableReturn = s.MaxUsable 
		FROM @VolumeSpaces s
	WHERE s.MaxUsable > 0
		AND DB_name (s.DatabaseId ) = @DbName
		AND s.LogicalName = @DbLogicalName;

	SET @MaxUsable = @MaxUsableReturn;

	IF @@ERROR <> 0 GOTO ErrorHandler

	RETURN 1

	ErrorHandler:
	RETURN -1 
END
GO
GRANT EXECUTE ON p_dba19_sys_DMGetDBDiskSpaceByLogicalName TO [db_proc_exec] AS [dbo]
GO
