SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- ======================================================================================
-- dba19_mem_DMProcessAddressSpaceInfoSK
--
--
-- Calls:		None
--
-- Description:	Get the process space memory numbers.
--
--  https://www.sqlskills.com/blogs/glenn/category/dmv-queries/
--
--				SQL Server Process Address space info  (Query 29) (Process Memory) 
--				(shows whether locked pages is enabled, among other things)
--				You want to see 0 for process_physical_memory_low
--				You want to see 0 for process_virtual_memory_low
--				This indicates that you are not under internal memory pressure
--				Get CPU utilization by database (adapted from Robert Pearl)  (Query 20) 
--				(CPU Usage by Database)
-- 
-- Date			Modified By			Changes
-- 10/17/2019   Aron E. Tekulsky    Initial Coding.
-- 10/17/2019   Aron E. Tekulsky    Update to Version 140.
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

	SELECT physical_memory_in_use_kb/1024 AS [SQL Server Memory Usage (MB)],
		   large_page_allocations_kb, locked_page_allocations_kb, page_fault_count, 
		   memory_utilization_percentage, available_commit_limit_kb, 
		   process_physical_memory_low, process_virtual_memory_low
		FROM sys.dm_os_process_memory WITH (NOLOCK) OPTION (RECOMPILE);

END
GO
