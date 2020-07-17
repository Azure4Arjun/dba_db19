USE DBA_DB19
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

IF object_id(N'dbo.v_dba19_sys_GetAGSecondary', 'V') IS NOT NULL
	DROP VIEW dbo.v_dba19_sys_GetAGSecondary
GO

-- ======================================================================================
-- v_dba19_sys_GetAGSecondary
--
--
-- Calls:		None
--
-- Description:	
-- 
-- Date			Modified By			Changes
-- 04/20/2016   Aron E. Tekulsky    Initial Coding.
-- 02/15/2018   Aron E. Tekulsky    Update to V140.
-- 05/19/2020   Aron E. Tekulsky    Update to V150.
-- ======================================================================================
--	Copyright©2001 - 2025 Aron Tekulsky.  World wide rights reserved.
--	Use of this code is free of charge but does not in any way imply transfer of 
--	Copyright ownership to the user.
-- ======================================================================================

CREATE VIEW dbo.v_dba19_sys_GetAGSecondary AS
	SELECT TOP 1000 s.[replica_id]
			,s.[group_id]
			,s.[is_local]
			,s.[role]
			,s.[role_desc]
			,s.[operational_state]
			,s.[operational_state_desc]
			,s.[connected_state]
			,s.[connected_state_desc]
			,s.[recovery_health]
			,s.[recovery_health_desc]
			,s.[synchronization_health]
			,s.[synchronization_health_desc]
			,s.[last_connect_error_number]
			,s.[last_connect_error_description]
			,s.[last_connect_error_timestamp]
			,c.[replica_server_name]
		FROM [master].[sys].[dm_hadr_availability_replica_states] s
			JOIN [master].[sys].[dm_hadr_availability_replica_cluster_states] c ON (s.replica_id = c.replica_id)
	WHERE s.role = 2;

