USE DBA_DB19
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

IF object_id(N'dbo.v_dba19_sys_RowLength', 'V') IS NOT NULL
	DROP VIEW dbo.v_dba19_sys_RowLength
GO

-- ======================================================================================
-- v_dba19_sys_RowLength
--
--
-- Calls:		None
--
-- Description:	
-- 
-- Date			Modified By			Changes
-- 02/14/2014   Aron E. Tekulsky    Initial Coding.
-- 02/13/2018   Aron E. Tekulsky    Update to V140.
-- 05/19/2020   Aron E. Tekulsky    Update to V150.
-- ======================================================================================
--	Copyright©2001 - 2025 Aron Tekulsky.  World wide rights reserved.
--	Use of this code is free of charge but does not in any way imply transfer of 
--	Copyright ownership to the user.
-- ======================================================================================

CREATE VIEW dbo.v_dba19_sys_RowLength AS
	SELECT TOP 100 PERCENT a.name AS name, SUM(b.length) AS rowlength, 8060 - SUM(b.length) AS max8060
		FROM sys.sysobjects a 
			INNER JOIN sys.syscolumns b ON a.id = b.id
	WHERE (a.xtype = 'U')
	GROUP BY a.name
	ORDER BY a.name;
