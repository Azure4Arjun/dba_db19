SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- ======================================================================================
-- dba16_sys_GetAllReplicaStatus
--
--
-- Calls:		None
--
-- Description:	Get teh status of all AG replicas.
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

/****** Script for SelectTopNRows command from SSMS  ******/
	SELECT TOP 1000 
		r.replica_server_name ,
	  		--,c.[group_id]
  --    ,c.[group_database_id]
      --,
	  c.[database_name]
      --,c.[truncation_lsn]
	--s.[replica_id]
      --,s.[group_id]
      --,
	  ,s.[is_local]
      --,s.[role]
      ,s.[role_desc]
      --,s.[operational_state]
      ,s.[operational_state_desc]
      --,s.[connected_state]
      ,s.[connected_state_desc]
      --,s.[recovery_health]
      ,s.[recovery_health_desc]
      --,s.[synchronization_health]
      ,s.[synchronization_health_desc]
      --,s.[last_connect_error_number]
      ,s.[last_connect_error_description]
      ,s.[last_connect_error_timestamp]
		FROM [master].[sys].[dm_hadr_availability_replica_states] s
	 		JOIN [master].[sys].[availability_databases_cluster] c ON (c.group_id = s.group_id )
			JOIN [master].[sys].[availability_replicas] r ON (s.replica_id = r.replica_id )
END
GO
