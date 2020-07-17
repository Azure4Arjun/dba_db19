SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- ======================================================================================
-- p_dba19_sys_DMGetDiskSpaceByLogicalVolumeName
--
-- Arguments:	@Lvn			nvarchar(512),
--				@MaxUsableMB	bigint OUTPUT
--
-- CallS:		None
--
-- Called BY:	p_dba19_alt_Set1105Error
--
-- Description:	Get a listing of the disk space for all disks that are part 
--				of SQL Server. Requires view system state permisisons.
--				Return the amount of space left on the disk.
-- 
-- Date			Modified By			Changes
-- 11/28/2016   Aron E. Tekulsky    Initial Coding.
-- 02/18/2018   Aron E. Tekulsky    Update to Version 140.
-- 05/26/2020   Aron E. Tekulsky    Update to Version 150.
-- ======================================================================================
--	Copyright©2001 - 2025 Aron Tekulsky.  World wide rights reserved.
--	Use of this code is free of charge but does not in any way imply transfer of 
--	Copyright ownership to the user.
-- ======================================================================================
--
CREATE PROCEDURE p_dba19_sys_DMGetDiskSpaceByLogicalVolumeName 
	-- Add the parameters for the stored procedure here
	@Lvn			nvarchar(512),
	@MaxUsableMB	bigint OUTPUT
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;

	DECLARE @Lvn2			nvarchar(512)

	DECLARE @VolumeSpaces AS TABLE (
		VolumeMountPoint	nvarchar(512),
		VolumeId			nvarchar(512),
		LogicalVolumeName	nvarchar(512),
		FileSystemType		nvarchar(512),
		TotalMB				bigint,
		AvailableMB			bigint,
		UsedSpace			bigint,
		EightyPercent		bigint,
		MaxUsable			bigint)
			
	INSERT INTO @VolumeSpaces 
		(VolumeMountPoint,VolumeId,LogicalVolumeName,FileSystemType, TotalMB, AvailableMB, UsedSpace, EightyPercent, MaxUsable)
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
		FROM sys.master_files AS f
			CROSS APPLY sys.dm_os_volume_stats(f.database_id, f.file_id) AS vs
	ORDER BY vs.volume_mount_point;

	-- get part of lvn to match up with.
	SET @Lvn2 = @Lvn;

	--SELECT VolumeMountPoint,VolumeId,LogicalVolumeName,FileSystemType, TotalMB AS DTotMB, AvailableMB AS DAvailMB, 
	--		UsedSpace AS DUsedMB, EightyPercent AS Pct80MB, MaxUsable AS MaxUsableMB
	SELECT @MaxUsableMB = MaxUsable
		FROM @VolumeSpaces
	WHERE LogicalVolumeName = @Lvn;


	IF @@ERROR <> 0 GOTO ErrorHandler

	RETURN 1

	ErrorHandler:
	RETURN -1 
END
GO
GRANT EXECUTE ON p_dba19_sys_DMGetDiskSpaceByLogicalVolumeName TO [db_proc_exec] AS [dbo]
GO
