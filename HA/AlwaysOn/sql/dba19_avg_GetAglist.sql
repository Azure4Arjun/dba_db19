SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- ======================================================================================
-- dba19_avg_GetAglist
--
--
-- Calls:		None
--
-- Description:	Get alis of all AG's'.
-- 
-- Date			Modified By			Changes
-- 11/18/2016   Aron E. Tekulsky    Initial Coding.
-- 12/27/2017   Aron E. Tekulsky    Update to Version 140.
-- 08/07/2020   Aron E. Tekulsky    Update to Version 150.
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

	SELECT TOP 1000 
			r.[replica_server_name] ,g.[name] as AGname
			,l.[dns_name] as ListenerName     
			,i.[network_subnet_ip]
			,i.[ip_address]
			,i.[ip_subnet_mask]
			,l.[port]
			,i.[state_desc]
			,c.[database_name]
		--	,l.[is_conformant]
		  --,l.[ip_configuration_string_from_cluster]
		   --,g.[failure_condition_level]
		  --,g.[health_check_timeout]
		  --,g.[automated_backup_preference]
			,g.[automated_backup_preference_desc]
		  --,r.[endpoint_url]
		  --,r.[availability_mode]
			,r.[availability_mode_desc]
		  --,r.[failover_mode]
			,r.[failover_mode_desc]
			,r.[session_timeout]
		  --,r.[primary_role_allow_connections]
			,r.[primary_role_allow_connections_desc]
		  --,r.[secondary_role_allow_connections]
			,r.[secondary_role_allow_connections_desc]
			,r.[create_date]
			,CASE ISNULL(r.[create_date], '')
				WHEN '' THEN
					'Secondary'
				ELSE 
					'Primary'
				END AS DBStatus
			,r.[modify_date]
			,r.[backup_priority]
			,r.[read_only_routing_url]
			,i.[is_dhcp]
		  --,i.[network_subnet_prefix_length]
		  --,i.[network_subnet_ipv4_mask]
			,i.[state]
		  --,c.[truncation_lsn]
		FROM [master].[sys].[availability_group_listeners] l
			JOIN [master].[sys].[availability_groups] g ON (g.[group_id] = l.group_id)
			JOIN [master].[sys].[availability_replicas] r ON (r.group_id = g.group_id)
			JOIN [master].[sys].[availability_group_listener_ip_addresses] i ON (i.listener_id = l.listener_id )
			JOIN [master].[sys].[availability_databases_cluster] c ON (c.group_id = l.group_id )
	ORDER BY DBStatus, r.[replica_server_name], g.[name] ASC;

END
GO
