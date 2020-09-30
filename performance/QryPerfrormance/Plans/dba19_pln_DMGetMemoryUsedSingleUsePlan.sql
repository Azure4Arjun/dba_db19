SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- ======================================================================================
-- dba19_pln_DMGetMemoryUsedSingleUsePlan
--
--
-- Calls:		None
--
-- Description:	
-- 
-- Date			Modified By			Changes
-- 10/16/2013   Aron E. Tekulsky    Initial Coding.
-- 02/24/2018   Aron E. Tekulsky    Update to Version 140.
-- 08/22/2020   Aron E. Tekulsky    Update to Version 150.
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

--	SELECT SUM(awe_allocated_kb)
--		FROM sys.dm_os_memory_clerks;

	SELECT objtype AS [CacheType]
			, count_big(*) AS [Total Plans]
			, sum(cast(size_in_bytes as decimal(18,2)))/1024/1024 AS [Total MBs]
			, avg(usecounts) AS [Avg Use Count]
		 , sum(cast((CASE WHEN usecounts = 1 THEN size_in_bytes ELSE 0 END) as decimal(18,2)))/1024/1024 AS [Total MBs - USE Count 1]
			, sum(CASE WHEN usecounts = 1 THEN 1 ELSE 0 END) AS [Total Plans - USE Count 1]
		FROM sys.dm_exec_cached_plans
	GROUP BY objtype

	ORDER BY [Total MBs - USE Count 1] DESC;

END
GO
