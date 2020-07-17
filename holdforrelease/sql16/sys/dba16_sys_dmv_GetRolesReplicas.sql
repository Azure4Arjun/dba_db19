SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- ======================================================================================
-- dba16_sysdmv_GetRolesReplicas
--
--
-- Calls:		None
--
-- Description:	Get a listing of the roles for each replica.
-- 
-- Date			Modified By			Changes
-- 06/17/2016   Aron E. Tekulsky    Initial Coding.
-- 10/25/2017   Aron E. Tekulsky    Update to Version 140.
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

/****** Script for SelectTopNRows command from SSMS  ******/
	SELECT  d.name
		--s.[replica_id]
      --,s.[group_id]
      --,s.[is_local]
      ,s.[role]
      ,s.[role_desc]
      --,s.[operational_state]
      --,s.[operational_state_desc]		
      --,s.[connected_state]
      --,s.[connected_state_desc]
      --,s.[recovery_health]
      --,s.[recovery_health_desc]
      --,s.[synchronization_health]
      --,s.[synchronization_health_desc]
      --,s.[last_connect_error_number]
      --,s.[last_connect_error_description]
      --,s.[last_connect_error_timestamp]
		FROM [master].[sys].[dm_hadr_availability_replica_states] s
			JOIN sys.databases d ON (s.replica_id = d.replica_id )
	WHERE s.role = 1;

END
GO
