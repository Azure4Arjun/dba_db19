SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- ======================================================================================
-- dba19_qry_DMGetQueryCachePlanSpecificIndexSK
--
--
-- Calls:		None
--
-- Description:	Identify all the queries that were using a specific index using
--				Extended Events
--
-- https://www.sqlskills.com/blogs/jonathan/finding-what-queries-in-the-plan-cacheuse-a-specific-index/
-- 
-- Date			Modified By			Changes
-- 12/07/2018	Aron E. Tekulsky	Initial Coding.
-- 05/13/2019   Aron E. Tekulsky    Update to Version 140.
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

	DECLARE @IndexName AS NVARCHAR(128) = 'PK__TestTabl__FFEE74517ABC33CD';

	--— Make sure the name passed is appropriately quoted
	IF (
		LEFT(@IndexName, 1) <> '['
		AND RIGHT(@IndexName, 1) <> ']'
		)
		SET @IndexName = QUOTENAME(@IndexName);

	--–Handle the case where the left or right was quoted manually but not the opposite side
	IF LEFT(@IndexName, 1) <> '['
		SET @IndexName = '[' + @IndexName;

	IF RIGHT(@IndexName, 1) <> ']'
		SET @IndexName = @IndexName + ']';
			--— Dig into the plan cache and find all plans using this index;

	WITH XMLNAMESPACES 
		(DEFAULT 'http://schemas.microsoft.com/sqlserver/2004/07/showplan') 
	SELECT stmt.value ('(@StatementText)[1]','varchar(max)') AS SQL_Text
			,obj.value ('(@Database)[1]','varchar(128)'	) AS DatabaseName
			,obj.value ('(@Schema)[1]'	,'varchar(128)'	) AS SchemaName
			,obj.value ('(@Table)[1]','varchar(128)') AS TableName
			,obj.value ('(@Index)[1]','varchar(128)') AS IndexName
			,obj.value ('(@IndexKind)[1]','varchar(128)') AS IndexKind
			,cp.plan_handle
			,query_plan 
		FROM sys.dm_exec_cached_plans AS cp CROSS APPLY sys.dm_exec_query_plan(plan_handle) AS qp 
			CROSS APPLY query_plan.nodes('/ShowPlanXML/BatchSequence/Batch/Statements/StmtSimple') AS batch(stmt) 
			CROSS APPLY stmt.nodes('.//IndexScan/Object[@Index=sql:variable("@IndexName")]') AS idx(obj)
			OPTION (MAXDOP 1,RECOMPILE);

END
GO
