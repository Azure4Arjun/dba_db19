SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- ======================================================================================
-- dba19_dig_DMGetSpidWIsolationLevelsSA
--
--
-- Calls:		None
--
-- Description:	Get a listing of all spids including the isolation level.
--
-- https://blog.sqlauthority.com/2018/06/07/sql-server-how-to-know-transaction-isolation-level-for-each-session/
-- 
-- Date			Modified By			Changes
-- 06/07/2018   Aron E. Tekulsky    Initial Coding.
-- 08/16/2018   Aron E. Tekulsky    Update to Version 140.
-- 08/11/2020   Aron E. Tekulsky    Update to Version 150.
-- ======================================================================================
--	Copyright©2001 - 2025 Aron Tekulsky.  World wide rights reserved.
--	Use of this code is free of charge but does not in any way imply transfer of 
--	Copyright ownership to the user.
-- ======================================================================================
--
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;

	SELECT r.session_id, r.start_time, r.status, r.total_elapsed_time,
			CASE r.transaction_isolation_level
				WHEN 1 THEN 'ReadUncomitted'
				WHEN 2 THEN 'ReadCommitted'
				WHEN 3 THEN 'Repeatable'
				WHEN 4 THEN 'Serializable'
				WHEN 5 THEN 'Snapshot'
				ELSE 'Unspecified' 
			END AS transaction_isolation_level,
			s.text, p.query_plan
		FROM sys.dm_exec_requests r
			CROSS APPLY sys.dm_exec_sql_text(sql_handle) s
			CROSS APPLY sys.dm_exec_query_plan(plan_handle) p;

END
GO
