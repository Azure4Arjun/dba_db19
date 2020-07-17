SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- ======================================================================================
-- dba16_dig_DMGetQueryResourceSemaphores
--
--
-- Calls:		None
--
-- Description:	
-- 
-- Date			Modified By			Changes
-- 05/06/2019   Aron E. Tekulsky    Initial Coding.
-- 05/06/2019   Aron E. Tekulsky    Update to Version 140.
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

	SELECT SUM(total_memory_kb) AS TotalSemaphoreMemory
		FROM sys.dm_exec_query_resource_semaphores;
END
GO
