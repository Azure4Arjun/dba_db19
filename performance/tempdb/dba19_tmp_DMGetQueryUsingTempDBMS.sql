SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- ======================================================================================
-- dba19_tmp_DMGetQueryUsingTempDBMS
--
--
-- Calls:		None
--
-- Description:	This script returns space used in tempdb only, regardless of the
--				db context it’s run in, and it only works for tempdb.
--
--	Modified from http://blogs.msdn.com/sqlserverstorageengine/archive/2009/01/12/
--	tempdb-monitoring-and-troubleshooting-out-of-space.aspx
-- 
-- Date			Modified By			Changes
-- 10/11/2014   Aron E. Tekulsky    Initial Coding.
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

	SELECT t1.session_id
			, t1.request_id
			, task_alloc_GB = cast((t1.task_alloc_pages * 8./1024./1024.) AS
			numeric(10,1))
			, task_dealloc_GB = cast((t1.task_dealloc_pages * 8./1024./1024.) AS
			numeric(10,1))
			, host= CASE WHEN t1.session_id <= 50 THEN 'SYS' ELSE s1.host_name END
			, s1.login_name
			, s1.status
			, s1.last_request_start_time
			, s1.last_request_end_time
			, s1.row_count
			, s1.transaction_isolation_level
			, query_text=
			coalesce((SELECT SUBSTRING(text, t2.statement_start_offset/2 + 1,
				(CASE WHEN statement_end_offset = -1
				THEN LEN(CONVERT(nvarchar(max),text)) * 2
				ELSE statement_end_offset
				END - t2.statement_start_offset)/2)
			FROM sys.dm_exec_sql_text(t2.sql_handle)) , 'Not currently executing')
			, query_plan=(SELECT query_plan
		FROM sys.dm_exec_query_plan(t2.plan_handle))
	FROM
		(SELECT session_id, request_id
				, task_alloc_pages=sum(internal_objects_alloc_page_count +
				user_objects_alloc_page_count)
				, task_dealloc_pages = sum
				(internal_objects_dealloc_page_count +
				user_objects_dealloc_page_count)
			FROM sys.dm_db_task_space_usage
		GROUP BY session_id, request_id) AS t1
			LEFT JOIN sys.dm_exec_requests AS t2 ON t1.session_id = t2.session_id
														AND t1.request_id = t2.request_id
			LEFT JOIN sys.dm_exec_sessions AS s1 ON t1.session_id=s1.session_id
		WHERE t1.session_id > 50 -- ignore system unless you suspect there's a problem there
			AND t1.session_id <> @@SPID -- ignore this request itself
		ORDER BY t1.task_alloc_pages DESC;

END
GO
