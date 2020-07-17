USE DBA_DB19
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

IF object_id(N'dbo.v_dba19_sys_MaxBackupJobDate', 'V') IS NOT NULL
	DROP VIEW dbo.v_dba19_sys_MaxBackupJobDate
GO

-- ======================================================================================
-- v_dba19_sys_MaxBackupJobDate
--
--
-- Calls:		None
--
-- Description:	
-- 
-- Date			Modified By			Changes
-- 10/23/2008   Aron E. Tekulsky    Initial Coding.
-- 02/13/2018   Aron E. Tekulsky    Update to V140.
-- 05/19/2020   Aron E. Tekulsky    Update to V150.
-- ======================================================================================
--	Copyright©2001 - 2025 Aron Tekulsky.  World wide rights reserved.
--	Use of this code is free of charge but does not in any way imply transfer of 
--	Copyright ownership to the user.
-- ======================================================================================

CREATE VIEW dbo.v_dba19_sys_MaxBackupJobDate AS	
	SELECT  h.job_id, max(h.run_date) AS maxrundate
		FROM msdb.dbo.sysjobhistory h
			JOIN msdb.dbo.sysjobs j ON (h.job_id = j.job_id)
			JOIN msdb.dbo.syscategories c ON (j.category_id = c.category_id)
	WHERE h.step_id = 0 AND
--		datediff(d,CONVERT(datetime,convert(char(8),h.run_date)),GETDATE()) >= 0 AND
		c.name = 'Database Maintenance'
		AND (j.name LIKE ('%User Maint%') OR j.name LIKE ('%System Maint%'))
	GROUP BY h.job_id;
