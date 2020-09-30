SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- ======================================================================================
-- dba19_tmp_DMTempdbSpaceUsageAK
--
--
-- Calls:		None
--
-- Description:	Get tempdb space usage.
-- 
--	Practical Monitoring of Tempdb - Andrew Kelly - SQL Saturday Philadelphia 2019
--
--  See Troubleshooting Insufficient Disk Space in TempDB in BOL
-- http://technet.microsoft.com/en-US/library/ms176029(v=SQL.105).aspx
--
-- Working with TempDB in SQL2005
-- http://technet.microsoft.com/en-us/library/cc966545.aspx
-- 
-- Date			Modified By			Changes
-- 05/04/2019   Aron E. Tekulsky    Initial Coding.
-- 05/04/2019   Aron E. Tekulsky    Update to Version 140.
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

	USE tempdb;

	--  Shows the amounts of pages & space free and used in tempdb by all session
	SELECT 'Report pages & freespace'as ReportName, SUM(unallocated_extent_page_count) AS [Free Pages], 
			CAST((SUM(unallocated_extent_page_count)/131072.0) AS DECIMAL(10,2)) AS [Free Space GB],
			SUM(version_store_reserved_page_count) AS [Version Store Pages Used],
			CAST((SUM(version_store_reserved_page_count)/131072.0) AS DECIMAL(10,2)) AS [Version Store Space GB],
			SUM(user_object_reserved_page_count) AS [User Object Pages Used],
			CAST((SUM(user_object_reserved_page_count)/131072.0) AS DECIMAL(10,2)) AS [User Object Space GB],
			SUM(internal_object_reserved_page_count) AS [Internal Object Pages Used],
			CAST((SUM(internal_object_reserved_page_count)/131072.0) AS DECIMAL(10,2)) AS [Internal Object Space GB]
		FROM sys.dm_db_file_space_usage;
		
		--  Shows any open or active transactions
		SELECT 'Report Open or Active transactions' as ReprtName,s.login_name, a.*  --transaction_id
			FROM sys.dm_tran_active_snapshot_database_transactions AS a
				INNER JOIN sys.dm_exec_sessions AS s ON a.session_id = s.session_id
		ORDER BY a.elapsed_time_seconds DESC;
		
		--  Shows the [current request only] usage of Tempdb by Session
		SELECT 'Current Use' AS [Report Type], * 
			FROM (
				SELECT session_id, 
						SUM(user_objects_alloc_page_count) - SUM(user_objects_dealloc_page_count) AS user_objects_current_alloc_page_count ,
						(SUM(user_objects_alloc_page_count) - SUM(user_objects_dealloc_page_count)) / 131072.0 AS [User GB],
						SUM(internal_objects_alloc_page_count) - SUM(internal_objects_dealloc_page_count) AS internal_objects_current_alloc_page_count ,
						(SUM(internal_objects_alloc_page_count) - SUM(internal_objects_dealloc_page_count)) / 131072.0 AS [Internal GB]
					FROM sys.dm_db_task_space_usage 
			--WHERE session_id > 50
				GROUP BY session_id
				HAVING (SUM(internal_objects_alloc_page_count) - SUM(internal_objects_dealloc_page_count) > 0)
					OR (SUM(user_objects_alloc_page_count) - SUM(user_objects_dealloc_page_count) > 0)) AS [SessionCounts]
				ORDER BY [User GB] + [Internal GB] DESC ;


	--  Shows historical tempdb space usage by session. May not reflect current operation.
	--  Actual current usage may only update once the action is complete
	SELECT TOP 10 'Historical Use' AS [Report Type], 
			session_id AS [Session ID], 
			(SELECT CASE WHEN es.login_name = '' THEN es.original_login_name 
						ELSE es.login_name
					END 
						FROM sys.dm_exec_sessions AS es 
			WHERE es.session_id = su.session_id) AS [Login Name],
			database_id AS [Database ID],
			CAST((user_objects_alloc_page_count/131072.0) AS DECIMAL(10,2)) - 
			CAST(((user_objects_dealloc_page_count + user_objects_deferred_dealloc_page_count) /131072.0) 
				AS DECIMAL(10,2)) AS [Current User Space GB],
			CAST((internal_objects_alloc_page_count/131072.0) AS DECIMAL(10,2)) - 
			CAST((internal_objects_dealloc_page_count/131072.0) AS DECIMAL(10,2)) AS [Current Int Space GB],
			CAST((user_objects_alloc_page_count/131072.0) AS DECIMAL(10,2)) AS [User Allocated GB],
			CAST((user_objects_dealloc_page_count/131072.0) AS DECIMAL(10,2)) AS [User DeAllocated GB],
			CAST((user_objects_deferred_dealloc_page_count/131072.0) AS DECIMAL(10,2)) AS [Deferred DeAllocated GB],
			CAST((internal_objects_alloc_page_count/131072.0) AS DECIMAL(10,2)) AS [Internal Allocated GB],
			CAST((internal_objects_dealloc_page_count/131072.0) AS DECIMAL(10,2)) AS [Internal DeAllocated GB]
		FROM tempdb.sys.dm_db_session_space_usage AS su
	ORDER BY ((user_objects_alloc_page_count -
				(user_objects_dealloc_page_count + user_objects_deferred_dealloc_page_count)) +
				(internal_objects_alloc_page_count - internal_objects_dealloc_page_count)) DESC ;


	--  Shows currently running tasks usage of tempdb page allocations and deallocations plus SQL Statement
	SELECT t1.session_id, t1.request_id, 
			t1.User_alloc, t1.User_dealloc, 
			t1.Internal_alloc, t1.Internal_dealloc,
		--  t2.sql_handle, t2.statement_start_offset, t2.statement_end_offset, t2.plan_handle
			SUBSTRING(t.[text], (t2.[statement_start_offset]/2) + 1,
			((CASE t2.[statement_end_offset] 
			WHEN -1 THEN DATALENGTH(t.[text]) 
				ELSE t2.[statement_end_offset] 
			END
			- t2.[statement_start_offset])/2) + 1) AS [Executed Statement]
		FROM (Select ts.session_id, ts.request_id,
			        SUM(ts.user_objects_alloc_page_count) AS User_alloc,
					SUM(ts.user_objects_dealloc_page_count) AS User_dealloc, 
					SUM(ts.internal_objects_alloc_page_count) AS Internal_alloc,
					SUM (ts.internal_objects_dealloc_page_count) AS Internal_dealloc 
				FROM sys.dm_db_task_space_usage AS ts 
			GROUP BY ts.session_id, ts.request_id) AS t1 
			INNER JOIN  sys.dm_exec_requests AS t2 ON  t1.session_id = t2.session_id
													AND (t1.request_id = t2.request_id)
			CROSS APPLY sys.dm_exec_sql_text(t2.sql_handle) AS t
	WHERE t1.session_id > 50
    ORDER BY t1.User_alloc + Internal_alloc DESC ;
	

END
GO
