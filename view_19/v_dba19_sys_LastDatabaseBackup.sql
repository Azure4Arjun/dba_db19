USE DBA_DB19
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

IF object_id(N'dbo.v_dba19_sys_LastDatabaseBackup', 'V') IS NOT NULL
	DROP VIEW dbo.v_dba19_sys_LastDatabaseBackup
GO

-- ======================================================================================
-- v_dba19_sys_LastDatabaseBackup
--
--
-- Calls:		None
--
-- Description:	
-- 
-- Date			Modified By			Changes
-- 02/12/2018   Aron E. Tekulsky    Initial Coding.
-- 02/12/2018   Aron E. Tekulsky    Update to V140.
-- 05/19/2020   Aron E. Tekulsky    Update to V150.
-- ======================================================================================
--	Copyright©2001 - 2025 Aron Tekulsky.  World wide rights reserved.
--	Use of this code is free of charge but does not in any way imply transfer of 
--	Copyright ownership to the user.
-- ======================================================================================

CREATE VIEW dbo.v_dba19_sys_LastDatabaseBackup AS
	SELECT 
		--s.server_name
		--,s.machine_name
		s.database_name
	    --,s.name
		,max(s.backup_start_date) AS max_backup_start_date
		--,s.backup_finish_date
		--,CASE s.TYPE
		--	WHEN 'D' THEN 'Database'
		--	WHEN 'I' THEn 'Differential database'
		--	WHEN 'L' THEN 'Log'
		--	WHEN 'F' THEN 'File or filegroup'
		--	WHEN 'G' THEN 'Differential file'
		--	WHEN 'P' THEN 'Partial'
		--	WHEN 'Q' THEN 'Differential partial'
		--	ELSE ''
		--	END AS Type
		,s.TYPE
	 --   ,convert(numeric(10,1),s.backup_size/1048576) AS backup_size_GB
		--,convert(varchar(10),s.software_major_version) + '.' + convert(varchar(10),s.software_minor_version) + '.' + convert(varchar(10),s.software_build_version) as software_version
		--,s.database_creation_date
		--,s.recovery_model
		--,s.expiration_date
		--,CASE s.compatibility_level 
		--	WHEN  80 THEN 'SQL Server 2000'
		--	WHEN  90 THEN 'SQL Server 2005'
		--	WHEN 100 THEN 'SQL Server 2008'
		--	END as Compatability_level
	FROM msdb.dbo.backupset s
	JOIN dbo.dba_database_expiration e ON (s.database_name = e.name)
	--WHERE s.type =  'D' 
	GROUP BY s.database_name, s.TYPE;
	 --order by s.database_name asc, s.backup_start_date desc


GO

GRANT REFERENCES ON [dbo].[v_dba19_sys_LastDatabaseBackup] TO [db_proc_exec] AS [dbo];
GO

GRANT SELECT ON [dbo].[v_dba19_sys_LastDatabaseBackup] TO [db_proc_exec] AS [dbo];
GO


