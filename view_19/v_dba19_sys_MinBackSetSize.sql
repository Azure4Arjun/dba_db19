USE DBA_DB19
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

IF object_id(N'dbo.v_dba19_sys_MinBackSetSize', 'V') IS NOT NULL
	DROP VIEW dbo.v_dba19_sys_MinBackSetSize
GO

-- ======================================================================================
-- v_dba19_sys_MinBackSetSize
--
--
-- Calls:		None
--
-- Description:	
-- 
-- Date			Modified By			Changes
-- 02/19/2014   Aron E. Tekulsky    Initial Coding.
-- 02/13/2018   Aron E. Tekulsky    Update to V140.
-- 05/19/2020   Aron E. Tekulsky    Update to V150.
-- ======================================================================================
--	Copyright©2001 - 2025 Aron Tekulsky.  World wide rights reserved.
--	Use of this code is free of charge but does not in any way imply transfer of 
--	Copyright ownership to the user.
-- ======================================================================================

CREATE VIEW dbo.v_dba19_sys_MinBackSetSize AS
	SELECT t_server_name, t_dbname, MIN(t_backup_start_date) AS maxdate
		FROM dbo.dba_backsetsize
	WHERE (t_GrowthPct = 0)
	GROUP BY t_server_name, t_dbname;
