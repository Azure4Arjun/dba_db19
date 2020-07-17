USE DBA_DB19
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

IF object_id(N'dbo.v_dba19_sys_MaxminBackSetSize', 'V') IS NOT NULL
	DROP VIEW dbo.v_dba19_sys_MaxminBackSetSize
GO

-- ======================================================================================
-- v_dba19_sys_MaxminBackSetSize
--
--
-- Calls:		None
--
-- Description:	
-- 
-- Date			Modified By			Changes
-- 04/25/2012   Aron E. Tekulsky    Initial Coding.
-- 02/18/2018   Aron E. Tekulsky    Update to V140.
-- 05/19/2020   Aron E. Tekulsky    Update to V150.
-- ======================================================================================
--	Copyright©2001 - 2025 Aron Tekulsky.  World wide rights reserved.
--	Use of this code is free of charge but does not in any way imply transfer of 
--	Copyright ownership to the user.
-- ======================================================================================

CREATE VIEW dbo.v_dba19_sys_MaxminBackSetSize AS
	SELECT t_server_name, t_dbname, MIN(t_backup_start_date) AS mindate, MAX(t_backup_start_date) AS maxdate
		FROM dbo.dba_backsetsize
	WHERE (t_GrowthPct = 0)
	GROUP BY t_server_name, t_dbname;

GO
