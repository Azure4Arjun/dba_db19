SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- ======================================================================================
-- dba16_dig_DMGetPendingIORequests
--
--
-- Calls:		None
--
-- Description:	
-- 
-- Date			Modified By			Changes
-- 02/16/2018   Aron E. Tekulsky    Initial Coding.
-- 01/01/2019	Aron E. Tekulsky	Update to Version 140.
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

	SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED

	SELECT database_id,
			file_id,
			io_stall,
			io_pending_ms_ticks,
			scheduler_address
		FROM sys.dm_io_virtual_file_stats(NULL, NULL) iovfs
			JOIN sys.dm_io_pending_io_requests as iopior ON (iovfs.file_handle = iopior.io_handle);
	

END
GO
