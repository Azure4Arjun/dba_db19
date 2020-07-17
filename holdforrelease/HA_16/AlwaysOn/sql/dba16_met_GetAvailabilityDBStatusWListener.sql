SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- ======================================================================================
-- dba16_met_GetAvailabilityDBStatusWListener
--
--
-- Calls:		None
--
-- Description:	
-- 
-- Date			Modified By			Changes
-- 01/15/2017   Aron E. Tekulsky    Initial Coding.
-- 02/16/2019   Aron E. Tekulsky    Update to Version 140.
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

	SELECT TOP 1000 'availability_databases_state'
			,@@SERVERNAME AS ServerName
			--,c.[group_id]
			-- ,c.[group_database_id]
			,c.[database_name]
			--,c.[truncation_lsn]
			--,s.[group_id]
			,s.[primary_replica]
			--,s.[primary_recovery_health]
			--,s.[primary_recovery_health_desc]
			--,s.[secondary_recovery_health]
			,s.[secondary_recovery_health_desc]
			--,s.[synchronization_health]
			--,s.[synchronization_health_desc]
			,g.name AS AGName
			,l.dns_name AS Listener
		FROM [master].[sys].[dm_hadr_availability_group_states] s
			JOIN [master].[sys].[availability_databases_cluster] c ON (c.group_id = s.group_id )
			JOIN [master].[sys].[availability_group_listeners] l ON (l.group_id = s.group_id )
			JOIN [master].[sys].[availability_groups] g ON (g.[group_id] = l.group_id);
END
GO
