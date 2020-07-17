USE [DBA_DB19]
GO

/****** Object:  View [dbo].[v_dba19_sys_DisasterDBListMirrored]    Script Date: 2/12/2018 6:38:43 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


-- ======================================================================================
-- v_dba19_sys_DisasterDBListMirrored
--
--
-- Calls:		None
--
-- Description:	This view gets data from the disaster dblist for    
--				principal databases only.
-- 
-- Date			Modified By			Changes
-- 06/01/2009   Aron E. Tekulsky    Initial Coding.
-- 06/08/2009   Aron E. Tekulsky	Add functionality to check for  
--									principal in mirrored pair only.
-- 06/12/2009   Aron E. Tekulsky	Add rownumber abd group by.
-- 04/19/2012	Aron E. Tekulsky	Update to v100.
-- 02/12/2018   Aron E. Tekulsky    Update to V140.
-- 05/19/2020   Aron E. Tekulsky    Update to V150.
-- ======================================================================================
--	Copyright©2001 - 2025 Aron Tekulsky.  World wide rights reserved.
--	Use of this code is free of charge but does not in any way imply transfer of 
--	Copyright ownership to the user.
-- ======================================================================================

CREATE VIEW [dbo].[v_dba19_sys_DisasterDBListMirrored] AS
    SELECT row_number()over(ORDER BY d.group_id ASC) as rownum,d.group_id, d.destination_server, d.destination_share, d.destination_path,
				d.source_server, d.source_share, d.source_path
		 FROM dba_disaster_dblist d
			JOIN master.sys.databases s ON (d.name = s.name)
			LEFT OUTER JOIN master.sys.database_mirroring p ON (s.database_id = p.database_id)
	WHERE (p.mirroring_role = 1 OR
        (p.mirroring_role IS null and d.name = 'dba_db16'))
    GROUP BY d.group_id, d.destination_server, d.destination_share, d.destination_path,
				d.source_server, d.source_share, d.source_path;





GO

GRANT REFERENCES ON [dbo].[v_dba19_sys_DisasterDBListMirrored] TO [db_proc_exec] AS [dbo]
GO

GRANT SELECT ON [dbo].[v_dba19_sys_DisasterDBListMirrored] TO [db_proc_exec] AS [dbo]
GO


