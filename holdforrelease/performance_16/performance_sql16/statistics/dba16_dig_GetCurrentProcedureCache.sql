SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- ======================================================================================
-- dba16_dig_GetCurrentProcedureCache
--
--
-- Calls:		None
--
-- Description:	see the current procedure cache for our DB.
--
-- https://www.mssqltips.com/sqlservertip/4266/sql-server-2016-database-scopedconfigurations-for-maxdop-procedure-cache-and-cross-database-queries/
--
-- Date			Modified By			Changes
-- 12/05/2018	Aron E. Tekulsky	Initial Coding.
-- 05/14/2019   Aron E. Tekulsky    Update to Version 140.
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
	SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED

	SELECT d.name AS [db_name]
			,count(*) AS nb_cached_entries
		FROM sys.dm_exec_cached_plans AS cp
			CROSS APPLY (
					SELECT CAST(pa.value AS INT) AS database_id
						FROM sys.dm_exec_plan_attributes(cp.plan_handle) AS pa
					WHERE pa.attribute = N'dbid') AS DB
			INNER JOIN sys.databases AS d ON d.database_id = DB.database_id
	--WHERE d.database_id=8 --database id for AdventureWorks2016CTP3
	GROUP BY d.name
	ORDER BY d.name;

END
GO
