USE DBA_DB19
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

IF object_id(N'dbo.v_dba19_sys_FtpList', 'V') IS NOT NULL
	DROP VIEW dbo.v_dba19_sys_FtpList
GO

-- ======================================================================================
-- v_dba19_sys_FtpList
--
--
-- Calls:		None
--
-- Description:	
-- 
-- Date			Modified By			Changes
-- 05/26/2009   Aron E. Tekulsky    Initial Coding.
-- 02/12/2018   Aron E. Tekulsky    Update to V140.
-- 05/19/2020   Aron E. Tekulsky    Update to V150.
-- ======================================================================================
--	Copyright©2001 - 2025 Aron Tekulsky.  World wide rights reserved.
--	Use of this code is free of charge but does not in any way imply transfer of 
--	Copyright ownership to the user.
-- ======================================================================================

CREATE VIEW dbo.v_dba19_sys_FtpList AS
    SELECT DISTINCT group_id, destination_server, destination_share, destination_path,
        source_server, source_share, source_path
    FROM dba_ftp_list;

