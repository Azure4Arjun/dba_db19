SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- ======================================================================================
-- dba19_cls_DMGetOSClusterNodes
--
--
-- Calls:		None
--
-- Description:	Get a list of all nodes of a cluster including status, current owner.
-- 
-- https://docs.microsoft.com/en-us/sql/relational-databases/system-dynamic-management-views/sys-dm-os-cluster-nodes-transact-sql?view=sql-server-ver15
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

	SELECT TOP (1000) [NodeName]
		  ,[status]
		  ,[status_description] -- 0 = up, 1 = down, 2 = paused, 3 = joining, -1 = unknown
		  ,[is_current_owner]
	  FROM [master].[sys].[dm_os_cluster_nodes]
END
GO
