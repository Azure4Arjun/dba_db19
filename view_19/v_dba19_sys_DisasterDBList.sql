USE DBA_DB19
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

IF object_id(N'dbo.v_dba19_sys_DisasterDBList', 'V') IS NOT NULL
	DROP VIEW dbo.v_dba19_sys_DisasterDBList
GO

-- ======================================================================================
-- v_dba19_sys_DisasterDBList
--
--
-- Calls:		None
--
-- Description:	
-- 
-- Date			Modified By			Changes
-- 12/05/2007   Aron E. Tekulsky    Initial Coding.
-- 02/12/2018   Aron E. Tekulsky    Update to V140.
-- ======================================================================================
--	Copyright©2001 - 2025 Aron Tekulsky.  World wide rights reserved.
--	Use of this code is free of charge but does not in any way imply transfer of 
--	Copyright ownership to the user.
-- ======================================================================================

CREATE VIEW dbo.v_dba19_sys_DisasterDBList AS
    SELECT distinct group_id, destination_server, destination_share, destination_path,
        source_server, source_share, source_path
		FROM dba_disaster_dblist;

