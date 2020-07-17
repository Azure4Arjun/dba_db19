USE DBA_DB19
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

IF object_id(N'dbo.v_dba19_sys_DBSizesSummary', 'V') IS NOT NULL
	DROP VIEW dbo.v_dba19_sys_DBSizesSummary
GO

-- ======================================================================================
-- v_dba19_sys_DBSizesSummary
--
--
-- Calls:		None
--
-- Description:	
-- 
-- Date			Modified By			Changes
-- 05/02/2012   Aron E. Tekulsky    Initial Coding.
-- 02/12/2018   Aron E. Tekulsky    Update to V140.
-- 05/19/2020   Aron E. Tekulsky    Update to V150.
-- ======================================================================================
--	Copyright©2001 - 2025 Aron Tekulsky.  World wide rights reserved.
--	Use of this code is free of charge but does not in any way imply transfer of 
--	Copyright ownership to the user.
-- ======================================================================================

CREATE VIEW dbo.v_dba19_sys_DBSizesSummary AS
	SELECT dbname, SUM(sizemb) AS dbtotal_size, dbid
		FROM dbo.v_dba19_sys_DBSizesDetail
		GROUP BY dbname, dbid;
		
GO
