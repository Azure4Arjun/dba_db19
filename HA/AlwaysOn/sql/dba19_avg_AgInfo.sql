SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- ======================================================================================
-- dba19_avg_AgInfo
--
--
-- Calls:		None
--
-- Description:	Get a list of all listeners etc.
-- 
-- Date			Modified By			Changes
-- 04/15/2016   Aron E. Tekulsky    Initial Coding.
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

--SELECT ac.database_name, l.dns_name, l.port, l.ip_configuration_string_from_cluster
--	FROM [master].[sys].[availability_databases_cluster] ac
--	JOIN [master].[sys].[availability_group_listeners] l ON (l.group_id = ac.group_id)

----
SELECT 'availability_databases_cluster', [group_id]
      ,[group_database_id]
      ,[database_name]
      ,[truncation_lsn]
  FROM [master].[sys].[availability_databases_cluster];

  SELECT 'availability_group_listener_ip_addresses', [listener_id]
      ,[ip_address]
      ,[ip_subnet_mask]
      ,[is_dhcp]
      ,[network_subnet_ip]
      ,[network_subnet_prefix_length]
      ,[network_subnet_ipv4_mask]
      ,[state]
      ,[state_desc]
  FROM [master].[sys].[availability_group_listener_ip_addresses];

  SELECT 'availability_group_listeners', [group_id]
      ,[listener_id]
      ,[dns_name]
      ,[port]
      ,[is_conformant]
      ,[ip_configuration_string_from_cluster]
  FROM [master].[sys].[availability_group_listeners];


  SELECT 'availability_groups', [group_id]
      ,[name]
      ,[resource_id]
      ,[resource_group_id]
      ,[failure_condition_level]
      ,[health_check_timeout]
      ,[automated_backup_preference]
      ,[automated_backup_preference_desc]
  FROM [master].[sys].[availability_groups];

  SELECT 'availability_groups_cluster', [group_id]
      ,[name]
      ,[resource_id]
      ,[resource_group_id]
      ,[failure_condition_level]
      ,[health_check_timeout]
      ,[automated_backup_preference]
      ,[automated_backup_preference_desc]
  FROM [master].[sys].[availability_groups_cluster];

  
  SELECT TOP 1000 'availability_replicas', [replica_id]
      ,[group_id]
      ,[replica_metadata_id]
      ,[replica_server_name]
      ,[owner_sid]
      ,[endpoint_url]
      ,[availability_mode]
      ,[availability_mode_desc]
      ,[failover_mode]
      ,[failover_mode_desc]
      ,[session_timeout]
      ,[primary_role_allow_connections]
      ,[primary_role_allow_connections_desc]
      ,[secondary_role_allow_connections]
      ,[secondary_role_allow_connections_desc]
      ,[create_date]
      ,[modify_date]
      ,[backup_priority]
      ,[read_only_routing_url]
  FROM [master].[sys].[availability_replicas]

END
GO
