SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- ======================================================================================
-- dba19_pln_DMGetQryPlanUsageCounts
--
--
-- Calls:		None
--
-- Description:	Get all query usage counts.
-- 
-- Date			Modified By			Changes
-- 08/27/2013	Aron E. Tekulsky	Initial Coding.
-- 05/13/2019	Aron E. Tekulsky    Update to Version 140.
-- 08/12/2020   Aron E. Tekulsky    Update to Version 150.
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

	SELECT DB_NAME(a.[dbid]) AS DBName, b.[cacheobjtype], b.[objtype],
			b.[usecounts],
			a.[dbid], a.[objectid], b.[size_in_bytes], a.[text],
			qp.query_plan
		FROM sys.dm_exec_cached_plans as b
			CROSS APPLY sys.dm_exec_sql_text (b.[plan_handle]) AS a
			CROSS APPLY sys.dm_exec_query_plan(b.plan_handle) AS qp
	WHERE a.[dbid] > 4
	--------AND DB_NAME(a.[dbid]) = 'WebCustSessionDB'
	--------AND a.[text] LIKE ('%UPDATE SESSIONS SET LASTACCESS%')
	ORDER BY [usecounts] DESC;

END
GO
