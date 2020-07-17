USE DBA_DB19
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

IF object_id(N'dbo.v_dba19_sys_LastRestore', 'V') IS NOT NULL
	DROP VIEW dbo.v_dba19_sys_LastRestore
GO

-- ======================================================================================
-- v_dba19_sys_LastRestore
--
--
-- Calls:		None
--
-- Description:	
-- 
-- Date			Modified By			Changes
-- 08/08/2012   Aron E. Tekulsky    Initial Coding.
-- 02/18/2018   Aron E. Tekulsky    Update to V140.
-- 05/19/2020   Aron E. Tekulsky    Update to V150.
-- ======================================================================================
--	Copyright©2001 - 2025 Aron Tekulsky.  World wide rights reserved.
--	Use of this code is free of charge but does not in any way imply transfer of 
--	Copyright ownership to the user.
-- ======================================================================================

CREATE VIEW dbo.v_dba19_sys_LastRestore AS
	SELECT h.destination_database_name, MAX(h.restore_date) AS max_restore_date
		FROM msdb.dbo.restorehistory AS h 
			LEFT OUTER JOIN dbo.dba_database_expiration AS e ON h.destination_database_name = e.name
	WHERE (h.restore_type = 'D')
	GROUP BY h.destination_database_name;

GO
