SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- ======================================================================================
-- dba16_dig_GetQueryPlanReuse
--
--
-- Calls:		None
--
-- Description:	
-- 
-- Date			Modified By			Changes
-- 09/05/2013   Aron E. Tekulsky    Initial Coding.
-- 02/24/2018   Aron E. Tekulsky    Update to V140.
-- ======================================================================================
--	Copyrightę2001 - 2025 Aron Tekulsky.  World wide rights reserved.
--	Use of this code is free of charge but does not in any way imply transfer of 
--	Copyright ownership to the user.
-- ======================================================================================
--
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED

	SELECT b.[cacheobjtype], b.[objtype], b.[usecounts],
			a.[dbid], a.[objectid], b.[size_in_bytes], a.[text]
		FROM sys.dm_exec_cached_plans as b
			CROSS APPLY sys.dm_exec_sql_text (b.[plan_handle]) AS a
	ORDER BY [usecounts] DESC;
END
GO
