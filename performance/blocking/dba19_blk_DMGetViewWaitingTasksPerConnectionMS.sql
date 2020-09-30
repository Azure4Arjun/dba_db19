SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- ======================================================================================
-- dba19_blk_DMGetViewWaitingTasksPerConnectionMS
--
--
-- Calls:		None
--
-- Description:	View waiting tasks per connection.
-- 
-- https://docs.microsoft.com/en-us/sql/relational-databases/system-dynamic-management-views/sys-dm-os-waiting-tasks-transact-sql?view=sql-server-ver15
--
-- Date			Modified By			Changes
-- 09/09/2020   Aron E. Tekulsky    Initial Coding.
-- 09/09/2020   Aron E. Tekulsky    Update to Version 150.
-- ======================================================================================
--	Copyright©2001 - 2025 Aron Tekulsky.  World wide rights reserved.
--	Use of this code is free of charge but does not in any way imply transfer of 
--	Copyright ownership to the user.
--
--  This code and information are provided "AS IS" without warranty of
--  any kind, either expressed or implied, including but not limited
--  to the implied warranties of merchantability and/or fitness for a
--  particular purpose.
-- ======================================================================================
--
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;

	SELECT st.text AS [SQL Text], c.connection_id, w.session_id, 
		  w.wait_duration_ms, w.wait_type, w.resource_address, 
		  w.blocking_session_id, w.resource_description, c.client_net_address, c.connect_time
		FROM sys.dm_os_waiting_tasks AS w
			INNER JOIN sys.dm_exec_connections AS c ON w.session_id = c.session_id 
			CROSS APPLY 
				(SELECT * FROM sys.dm_exec_sql_text(c.most_recent_sql_handle)) AS st 
				  WHERE w.session_id > 50 AND w.wait_duration_ms > 0
	ORDER BY c.connection_id, w.session_id;
END
GO
