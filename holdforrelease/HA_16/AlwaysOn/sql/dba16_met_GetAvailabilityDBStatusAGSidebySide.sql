SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- ======================================================================================
-- dba16_met_GetAvailabilityDBStatusAGSidebySide
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

	DECLARE @aglista TABLE (
		[ServerName] nvarchar(128),
		[cgroup_id] uniqueidentifier,
		[group_database_id] uniqueidentifier,
		[database_name] nvarchar(128),
		[sgroup_id] uniqueidentifier,
		[primary_replica] nvarchar(128),
		[primary_recovery_health] tinyint,
		[primary_recovery_health_desc] nvarchar(60),
		[secondary_recovery_health] tinyint,
		[secondary_recovery_health_desc] nvarchar(128)
	)

	DECLARE @aglistb TABLE (
		[ServerName] nvarchar(128),
		[cgroup_id] uniqueidentifier,
		[group_database_id] uniqueidentifier,
		[database_name] nvarchar(128),
		[sgroup_id] uniqueidentifier,
		[primary_replica] nvarchar(128),
		[primary_recovery_health] tinyint,
		[primary_recovery_health_desc] nvarchar(60),
		[secondary_recovery_health] tinyint,
		[secondary_recovery_health_desc] nvarchar(128)
	)

	INSERT INTO @aglista
		SELECT --'availability_databases_state'
				@@SERVERNAME AS ServerName
				,c.[group_id]
				,c.[group_database_id]
				,c.[database_name]
				--,c.[truncation_lsn]
				,s.[group_id]
				,s.[primary_replica]
				,isnull(s.[primary_recovery_health],'')
				,isnull(s.[primary_recovery_health_desc],'')
				,isnull(s.[secondary_recovery_health],'')
				,isnull(s.[secondary_recovery_health_desc],'')
				--,s.[synchronization_health]
				--,s.[synchronization_health_desc]
			FROM [master].[sys].[dm_hadr_availability_group_states] s
				JOIN [master].[sys].[availability_databases_cluster] c ON (c.group_id = s.group_id )
		WHERE --@@SERVERNAME <> 'WCNCPNGDBD01\DEV' AND
			s.[primary_recovery_health] = 1;

	INSERT INTO @aglistb
		SELECT --'availability_databases_state'
				@@SERVERNAME AS ServerName
				,c.[group_id]
				,c.[group_database_id]
				,c.[database_name]
				--,c.[truncation_lsn]
				,s.[group_id]
				,s.[primary_replica]
				,isnull(s.[primary_recovery_health],'')
				,isnull(s.[primary_recovery_health_desc],'')
				,isnull(s.[secondary_recovery_health],'')
				,isnull(s.[secondary_recovery_health_desc],'')
				--,s.[synchronization_health]
				--,s.[synchronization_health_desc]
			FROM [master].[sys].[dm_hadr_availability_group_states] s
				JOIN [master].[sys].[availability_databases_cluster] c ON (c.group_id = s.group_id )
		WHERE --@@SERVERNAME <> 'WCNCPNGDBD01\DEV' AND
			s.[secondary_recovery_health] = 1;

	SELECT *
		FROM @aglista;

--AA 42877D93-50F3-4790-AEA1-6AFF0C5B7D78
--BB 42877D93-50F3-4790-AEA1-6AFF0C5B7D78

	SELECT *
		FROM @aglistb;

	SELECT a.[ServerName], a.[cgroup_id], a.[group_database_id], a.[database_name],
			a.[sgroup_id], a.[primary_replica], isnull(a.[primary_recovery_health],''),
			isnull(a.[primary_recovery_health_desc],''), isnull(a.
			[secondary_recovery_health],''), isnull(a.[secondary_recovery_health_desc],'')
			,b.[ServerName] AS snb, b.[cgroup_id], b.[group_database_id], b.[database_name],
			b.[sgroup_id], b.[primary_replica], isnull(b.[primary_recovery_health],''),
			isnull(b.[primary_recovery_health_desc],''), isnull(b.
			[secondary_recovery_health],''), isnull(b.[secondary_recovery_health_desc],'')
		FROM @aglista a
			JOIN @aglistb b ON (a.group_database_id = b.group_database_id );
	--WHERE a.primary_recovery_health = 1
	--ORDER BY a.database_name ASC;

	--DROP TABLE @aglista;
	--DROP TABLE @aglistb;
END
GO
