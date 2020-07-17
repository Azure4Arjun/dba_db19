SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- ======================================================================================
-- dba16_sys_GetDMHadrClusterNetworks
--
--
-- Calls:		None
--
-- Description:	Get a list of cluster networks.
-- 
-- Date			Modified By			Changes
-- 05/16/2016   Aron E. Tekulsky    Initial Coding.
-- 12/27/2017   Aron E. Tekulsky    Update to V140.
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
	SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED

/****** Script for SelectTopNRows command from SSMS  ******/
	SELECT TOP 1000 [member_name]
		,[network_subnet_ip]
		,[network_subnet_ipv4_mask]
		,[network_subnet_prefix_length]
		,[is_public]
		,[is_ipv4]
	FROM [master].[sys].[dm_hadr_cluster_networks];
END
GO
