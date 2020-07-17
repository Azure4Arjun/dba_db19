USE DBA_DB19
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

IF object_id(N'dbo.v_dba19_sys_LastDBBakNExpiration', 'V') IS NOT NULL
	DROP VIEW dbo.v_dba19_sys_LastDBBakNExpiration
GO

-- ======================================================================================
-- v_dba19_sys_LastDBBakNExpiration
--
--
-- Calls:		None
--
-- Description:	
-- 
-- Date			Modified By			Changes
-- 11/05/2010   Aron E. Tekulsky    Initial Coding.
-- 02/18/2018   Aron E. Tekulsky    Update to V140.
-- 05/19/2018   Aron E. Tekulsky    Update to V150.
-- ======================================================================================
--	Copyright©2001 - 2025 Aron Tekulsky.  World wide rights reserved.
--	Use of this code is free of charge but does not in any way imply transfer of 
--	Copyright ownership to the user.
-- ======================================================================================

CREATE VIEW dbo.v_dba19_sys_LastDBBakNExpiration AS
	SELECT 
		--server_name
		--,machine_name
		b.database_name
	    --,name
		,b.backup_start_date
		--,backup_finish_date
		--,CASE TYPE
		--	WHEN 'D' THEN 'Database'
		--	WHEN 'I' THEn 'Differential database'
		--	WHEN 'L' THEN 'Log'
		--	WHEN 'F' THEN 'File or filegroup'
		--	WHEN 'G' THEN 'Differential file'
		--	WHEN 'P' THEN 'Partial'
		--	WHEN 'Q' THEN 'Differential partial'
		--	ELSE ''
		--	END AS Type
	 --   ,convert(numeric(10,1),backup_size/1048576) AS backup_size_GB
		--,convert(varchar(10),software_major_version) + '.' + convert(varchar(10),software_minor_version) + '.' + convert(varchar(10),software_build_version) as software_version
		--,database_creation_date
		--,recovery_model
		,b.expiration_date
		--,CASE compatibility_level 
		--	WHEN  80 THEN 'SQL Server 2000'
		--	WHEN  90 THEN 'SQL Server 2005'
		--	WHEN 100 THEN 'SQL Server 2008'
		--	END as Compatability_level
	FROM msdb.dbo.backupset b
	JOIN v_dba19_sys_LastDatabaseBackup v ON (b.backup_start_date = v.max_backup_start_date) AND
										 (b.database_name = v.database_name) AND
										 (b.type = v.type)

	WHERE b.type =  'D' AND
		v.type = 'D'
	 --order by b.database_name asc, b.backup_start_date desc


GO


