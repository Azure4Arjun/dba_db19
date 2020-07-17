USE DBA_DB19
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

IF object_id(N'dbo.v_dba19_sys_MaxMinJobStatus', 'V') IS NOT NULL
	DROP VIEW dbo.v_dba19_sys_MaxMinJobStatus
GO

-- ======================================================================================
-- v_dba19_sys_MaxMinJobStatus
--
--
-- Calls:		None
--
-- Description:	
-- 
-- Date			Modified By			Changes
-- 11/27/2006   Aron E. Tekulsky    Initial Coding.
-- 02/12/2018   Aron E. Tekulsky    Update to V140.
-- 05/19/2020   Aron E. Tekulsky    Update to V150.
-- ======================================================================================
--	Copyright©2001 - 2025 Aron Tekulsky.  World wide rights reserved.
--	Use of this code is free of charge but does not in any way imply transfer of 
--	Copyright ownership to the user.
-- ======================================================================================

CREATE VIEW dbo.v_dba19_sys_MaxMinJobStatus AS
	SELECT j.name, max(h.run_date) AS maxrundate, max(h.run_time) AS maxruntime,
			min(h.run_date) as minrundate, min(h.run_time) as minruntime
		FROM msdb..sysjobs j
			JOIN msdb..sysjobhistory h ON (h.job_id = j.job_id)
	WHERE step_id = 0 
	GROUP BY j.name;

