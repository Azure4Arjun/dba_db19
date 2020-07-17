SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- ======================================================================================
-- dba16_cmp_GetDBCCCompletionTime
--
--
-- Calls:		None
--
-- Description:	Get an estimate of time remaining on a DBCC operation.
-- 
-- http://www.codewrecks.com/blog/index.php/2012/02/07/check-progress-of-dbcc-checkdb/
--
-- Date			Modified By			Changes
-- 08/01/2018   Aron E. Tekulsky    Initial Coding.
-- 08/01/2018   Aron E. Tekulsky    Update to V140.
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

	SELECT r.session_id AS [Session_Id]
		,r.command AS [command]
		,CONVERT(NUMERIC(6, 2), r.percent_complete) AS [% Complete]
		,GETDATE() AS [Current Time]
		,CONVERT(VARCHAR(20), DATEADD(ms, r.estimated_completion_time, GetDate()),20) AS [Estimated Completion Time]
		,CONVERT(NUMERIC(32, 2), r.total_elapsed_time / 1000.0 /60.0) AS [Elapsed Min]
		,CONVERT(NUMERIC(32, 2), r.estimated_completion_time / 1000.0 /60.0) AS [Estimated Min]
		,CONVERT(NUMERIC(32, 2), r.estimated_completion_time / 1000.0 / 60.0 /60.0) AS [Estimated Hours]
		,CONVERT(VARCHAR(1000), (
			SELECT SUBSTRING(TEXT, r.statement_start_offset / 2,
				CASE
					WHEN r.statement_end_offset = - 1 THEN 1000
					ELSE (r.statement_end_offset - r.statement_start_offset) /2
					END) 'Statement text'
				FROM sys.dm_exec_sql_text(sql_handle)))
			FROM sys.dm_exec_requests r
	WHERE command LIKE 'DBCC%';

END
GO
