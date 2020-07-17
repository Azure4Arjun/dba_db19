SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- ======================================================================================
-- dba_get_availabilitydatabsestatus
--
--
-- Calls:		None
--
-- Description:	Gt a list of AG DB status.
-- 
-- Date			Modified By			Changes
-- 05/02/2016   Aron E. Tekulsky    Initial Coding.
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

	SELECT TOP 1000 'availability_databases_state'
		--,c.[group_id]
  --    ,c.[group_database_id]
		,c.[database_name]
      --,c.[truncation_lsn]
		--,s.[group_id]
		,s.[primary_replica]
      --,s.[primary_recovery_health]
		,s.[primary_recovery_health_desc]
      --,s.[secondary_recovery_health]
		,s.[secondary_recovery_health_desc]
      --,s.[synchronization_health]
		,s.[synchronization_health_desc]
		FROM [master].[sys].[dm_hadr_availability_group_states] s
			JOIN [master].[sys].[availability_databases_cluster] c ON (c.group_id = s.group_id )


END
GO
