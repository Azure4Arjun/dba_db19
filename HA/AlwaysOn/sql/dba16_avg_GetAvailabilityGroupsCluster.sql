SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- ======================================================================================
-- dba16_avg_GetAvailabilityGroupsCluster
--
--
-- Calls:		None
--
-- Description:	Get a list of the AG clusters.
-- 
-- Date			Modified By			Changes
-- 06/07/2016   Aron E. Tekulsky    Initial Coding.
-- 12/27/2017   Aron E. Tekulsky    Update to Version 140.
-- 08/07/2020   Aron E. Tekulsky    Update to Version 150.
-- ======================================================================================
--	Copyrightę2001 - 2025 Aron Tekulsky.  World wide rights reserved.
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

	SELECT 'availability_groups_cluster', [group_id]
		 ,[name]
		 ,[resource_id]
		 ,[resource_group_id]
		 ,[failure_condition_level]
		 ,[health_check_timeout]
		 ,[automated_backup_preference]
		 ,[automated_backup_preference_desc]
		FROM [master].[sys].[availability_groups_cluster];

END
GO
