SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- ======================================================================================
-- dba16_sys_GetQryPlanUsageCounts
--
--
-- Calls:		None
--
-- Called BY:	None

-- Description:	Get all query usage counts.
-- 
-- Date			Modified By			Changes
-- 08/27/2013   Aron E. Tekulsky    Initial Coding.
-- 12/11/2017   Aron E. Tekulsky    Update to Version 140.
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

	SELECT b.[cacheobjtype], b.[objtype], b.[usecounts],
			a.[dbid], a.[objectid], b.[size_in_bytes], a.[text]
		FROM sys.dm_exec_cached_plans as b
			CROSS APPLY sys.dm_exec_sql_text (b.[plan_handle]) AS a
	ORDER BY [usecounts] DESC;
END
GO
