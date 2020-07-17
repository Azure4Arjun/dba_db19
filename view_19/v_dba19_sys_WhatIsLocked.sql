USE DBA_DB19
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

IF object_id(N'dbo.v_dba19_sys_WhatIsLocked', 'V') IS NOT NULL
	DROP VIEW dbo.v_dba19_sys_WhatIsLocked
GO

-- ======================================================================================
-- v_dba19_sys_WhatIsLocked
--
--
-- Calls:		None
--
-- Description:	
-- 
-- Date			Modified By			Changes
-- 02/14/2014   Aron E. Tekulsky    Initial Coding.
-- 02/13/2018   Aron E. Tekulsky    Update to V140.
-- 06/19/2020   Aron E. Tekulsky    Update to V150.
-- ======================================================================================
--	Copyright©2001 - 2025 Aron Tekulsky.  World wide rights reserved.
--	Use of this code is free of charge but does not in any way imply transfer of 
--	Copyright ownership to the user.
-- ======================================================================================

CREATE VIEW dbo.v_dba19_sys_WhatIsLocked AS
	SELECT Locks.request_session_id AS SessionID, Obj.Name AS LockedObjectName, DATEDIFF(second,ActTra.Transaction_begin_time, GETDATE()) AS Duration,
			ActTra.Transaction_begin_time, COUNT(*) AS Locks
		FROM sys.dm_tran_locks Locks
			JOIN sys.partitions Parti ON Parti.hobt_id = Locks.resource_associated_entity_id
			JOIN sys.objects Obj ON Obj.object_id = Parti.object_id
			JOIN sys.dm_exec_sessions ExeSess ON ExeSess.session_id = Locks.request_session_id
			JOIN sys.dm_tran_session_transactions TranSess ON ExeSess.session_id = TranSess.session_id
			JOIN sys.dm_tran_active_transactions ActTra ON TranSess.transaction_id = ActTra.transaction_id
	WHERE   resource_database_id = db_id() AND Obj.Type = 'U'
	GROUP BY ActTra.Transaction_begin_time,Locks.request_session_id, Obj.Name;