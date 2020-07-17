SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- ======================================================================================
-- dba16_dig_DMGetAllQryPlansStoredinQPC
--
--
-- Calls:		None
--
-- Description:	List all cached plans stored in the QPC.
--
-- https://dba.stackexchange.com/questions/182469/how-to-query-the-plan-cache-tofind-how-healthy-it-is
--
-- Date			Modified By			Changes
-- 12/12/2018	Aron E. Tekulsky	Initial Coding.
-- 05/13/2019   Aron E. Tekulsky    Update to Version 140.
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

	SELECT req.status, req.blocking_session_id ,req.command ,db_name
			(req.database_id), req.user_id ,req.wait_type ,
			req.open_transaction_count ,req.transaction_id ,
			req.estimated_completion_time ,req.cpu_time ,
			req.total_elapsed_time , req.reads , req.writes , req.logical_reads ,
			req.transaction_isolation_level , req.deadlock_priority ,
			req.row_count ,
			ecp.plan_handle, ecp.memory_object_address AS CompiledPlan_MemoryObject,
			omo.memory_object_address,omo.page_allocator_address ,--pages_allocated_count,
			omo.type, page_size_in_bytes
			------,omo.waiting_tasks_count
		FROM sys.dm_exec_cached_plans AS ecp
			JOIN sys.dm_os_memory_objects AS omo ON ecp.memory_object_address = omo.memory_object_address
													OR ecp.memory_object_address = omo.parent_address
	-- next line is exprimental
			JOIN sys.dm_exec_requests AS req ON (ecp.plan_handle = req.plan_handle )
	WHERE cacheobjtype = 'Compiled Plan';

END
GO
