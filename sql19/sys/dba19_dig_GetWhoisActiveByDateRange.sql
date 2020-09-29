SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- ======================================================================================
-- dba19_dig_GetWhoisActiveByDateRange
--
--
-- Calls:		None
--
-- Description:	List active items by date range.
-- 
-- Date			Modified By			Changes
-- 09/03/2020   Aron E. Tekulsky    Initial Coding.
-- 09/03/2020   Aron E. Tekulsky    Update to Version 150.
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

	DECLARE @FromDate	varchar(20)
	DECLARE @ToDate		varchar(20)

	-- Initialize
	SET @FromDate	= '2020-09-01 00:00:00';
	SET @ToDate		= '2020-09-02 23:59:00';

	SELECT [dd hh:mm:ss.mss] AS Elapsed_Time
		  ,[session_id]
		  ,[sql_text]
		  ,[sql_command]
		  ,[login_name]
		  ,[wait_info]
		  ,[tran_log_writes]
		  ,[CPU]
		  ,[tempdb_allocations]
		  ,[tempdb_current]
		  ,[blocking_session_id]
		  ,[reads]
		  ,[writes]
		  ,[physical_reads]
		  ,[query_plan]
		  ,[used_memory]
		  ,[status]
		  ,[tran_start_time]
		  ,[open_tran_count]
		  ,[percent_complete]
		  ,[host_name]
		  ,[database_name]
		  ,[program_name]
		  ,[start_time]
		  ,[login_time]
		  ,[request_id]
		  ,[collection_time]
	  FROM [Brent].[dbo].[WhoIsActive]
	WHERE [collection_time] >= @FromDate AND
		[collection_time] <= @ToDate;
END
GO
