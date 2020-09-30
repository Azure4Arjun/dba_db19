SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- ======================================================================================
-- dba19_dig_TuneCostThresholdForParallelism
--
--
-- Calls:		None
--
-- Description:	Search the plan cache for existing parallel plans and see the
--				cost associations to current plans that executed
--				parallel.
--
-- https://www.sqlskills.com/blogs/jonathan/tuning-cost-threshold-for-parallelism-fromthe-plan-cache/
-- 
-- Date			Modified By			Changes
-- 12/07/2018   Aron E. Tekulsky    Initial Coding.
-- 05/09/2019   Aron E. Tekulsky    Update to Version 140.
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

	WITH XMLNAMESPACES (DEFAULT 'http://schemas.microsoft.com/sqlserver/2004/07/showplan') 

	SELECT query_plan AS CompleteQueryPlan
			,n.value ('(@StatementText)[1]','VARCHAR(4000)') AS StatementText
			,n.value ('(@StatementOptmLevel)[1]','VARCHAR(25)') AS StatementOptimizationLevel
			,n.value ('(@StatementSubTreeCost)[1]','VARCHAR(128)') AS StatementSubTreeCost
			,n.query ('.') AS ParallelSubTreeXML
			,ecp.usecounts
			,ecp.size_in_bytes 
		FROM sys.dm_exec_cached_plans AS ecp 
			CROSS APPLY sys.dm_exec_query_plan(plan_handle) AS eqp 
			CROSS APPLY query_plan.nodes('/ShowPlanXML/BatchSequence/Batch/Statements/StmtSimple') AS qn(n) 
	WHERE n.query ('.').exist ('//RelOp[@PhysicalOp="Parallelism"]') = 1
	ORDER BY ecp.usecounts DESC;

END
GO
