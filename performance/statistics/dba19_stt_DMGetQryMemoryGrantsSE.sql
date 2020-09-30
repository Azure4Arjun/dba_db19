SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- ======================================================================================
-- dba19_stt_DMGetQryMemoryGrantsSE
--
--
-- Calls:		None
--
-- Description:	Get a list of memory gants.
--
-- https://dba.stackexchange.com/questions/96333/how-to-resolve-resource-semaphore-and-resource-semaphore-query-compile-wait-type
-- 
-- Date			Modified By			Changes
-- 05/06/2019   Aron E. Tekulsky    Initial Coding.
-- 05/06/2019   Aron E. Tekulsky    Update to Version 140.
-- 08/13/2020   Aron E. Tekulsky    Update to Version 150.
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

	SELECT g.[session_id], g.[request_id], g.[scheduler_id], g.[dop], g.[request_time], 
			g.[grant_time], g.[requested_memory_kb], g.[required_memory_kb], g.[used_memory_kb], g.[max_used_memory_kb], 
			g.[query_cost], g.[timeout_sec], g.[resource_semaphore_id], g.[queue_id], g.[wait_order],
			g.[is_next_candidate], g.[wait_time_ms], g.[plan_handle], g.[sql_handle], g.[group_id], 
			g.[pool_id], g.[is_small], g.[ideal_memory_kb], g.[reserved_worker_count], g.[used_worker_count],
			g.[max_used_worker_count], g.[reserved_node_bitmap]
		FROM sys.dm_exec_query_memory_grants g;

END
GO
