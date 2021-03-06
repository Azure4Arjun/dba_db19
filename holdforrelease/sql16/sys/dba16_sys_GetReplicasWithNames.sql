SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- ======================================================================================
-- dba16_sys_GetReplicasWithNames
--
--
-- Calls:		None
--
-- Description:	Get a listing of AG replicas.
-- 
-- Date			Modified By			Changes
-- 06/17/2016   Aron E. Tekulsky    Initial Coding.
-- 10/25/2017   Aron E. Tekulsky    Update to Version 140.
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

/****** Script for SelectTopNRows command from SSMS  ******/
	SELECT TOP 1000 d.name, r.[replica_id]
      ,r.[group_id]
      ,r.[replica_metadata_id]
      ,r.[replica_server_name]
      ,r.[owner_sid]
      ,r.[endpoint_url]
      ,r.[availability_mode]
      ,r.[availability_mode_desc]
      ,r.[failover_mode]
      ,r.[failover_mode_desc]
      ,r.[session_timeout]
      ,r.[primary_role_allow_connections]
      ,r.[primary_role_allow_connections_desc]
      ,r.[secondary_role_allow_connections]
      ,r.[secondary_role_allow_connections_desc]
      ,r.[create_date]
      ,r.[modify_date]
      ,r.[backup_priority]
      ,r.[read_only_routing_url]
		FROM [master].[sys].[availability_replicas] r
			JOIN sys.databases d ON (d.replica_id = r.replica_id )
	ORDER BY d.name asc;
END
GO
