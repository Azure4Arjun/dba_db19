SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- ======================================================================================
-- dba19_cls_DMIOClusteSharedDrives
--
--
-- Calls:		None
--
-- Description:	Get a list of the shared drives used in the cluster.
-- 
-- Date			Modified By			Changes
-- 07/15/2020   Aron E. Tekulsky    Initial Coding.
-- 07/15/2020   Aron E. Tekulsky    Update to Version 150.
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

	SELECT TOP (1000) [DriveName]
		FROM [master].[sys].[dm_io_cluster_shared_drives];

END
GO
