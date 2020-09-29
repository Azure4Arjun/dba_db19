SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- ======================================================================================
-- dba19_utl_DMGetVolumeSpace
--
--
-- Calls:		None
--
-- Description:	
-- 
-- Date			Modified By			Changes
-- 11/28/2016   Aron E. Tekulsky    Initial Coding.
-- 11/28/2016   Aron E. Tekulsky    Update to Version 150.
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
	SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;

	SELECT DISTINCT vs.volume_mount_point AS [Drive],
					----vs.volume_id ,
					vs.logical_volume_name AS [Drive Name],
					vs.file_system_type ,
					vs.total_bytes/1024/1024 AS [Drive Size (MB)],
					CONVERT(decimal(20,2),vs.available_bytes/1024/1024.0) AS [Drive Free Space (MB)],
					CONVERT(decimal(20,2),vs.available_bytes/1024/1024/1024.0) AS [Drive Free Space (GB)],
					CONVERT(decimal(20,2),vs.available_bytes/1024/1024/1024/1024.0) AS [Drive Free Space (TB)],
					CONVERT(decimal(20,2),((vs.total_bytes - vs.available_bytes)/1024/1024.0) ) AS [Used Space (MB)],
					CONVERT(decimal(20,2),(vs.total_bytes/1024/1024)*.8) AS [Eighty Percent (MB)],
					CASE 
						WHEN (((vs.total_bytes)*.8) - ((vs.total_bytes - vs.available_bytes))) > 0 THEN
							CONVERT(numeric(10,2),(((vs.total_bytes)*.8) - ((vs.total_bytes - vs.available_bytes))) /1024/1024 )
						ELSE 0
					END AS [Max Usable (MB)]--,
					----f.database_id , f.file_id
		FROM sys.master_files AS f
			CROSS APPLY sys.dm_os_volume_stats(f.database_id, f.file_id) AS vs
	ORDER BY vs.volume_mount_point ASC;

END
GO
