SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- ======================================================================================
-- dba16_dig_DMReportTopTempDBUsageAK
--
--
-- Calls:		None
--
-- Description:	Report top tempdb usage.
-- 
--	Practical Monitoring of Tempdb - Andrew Kelly - SQL Saturday Philadelphia 2019
--
-- Date			Modified By			Changes
-- 05/04/2019   Aron E. Tekulsky    Initial Coding.
-- 05/04/2019   Aron E. Tekulsky    Update to Version 140.
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

	SET ANSI_NULLS ON
	SET QUOTED_IDENTIFIER ON

	--  Shows the amounts of pages & space free and used in tempdb by all session
	SELECT 'Overall Use' AS [Report Type],
			CAST((SUM(unallocated_extent_page_count)/131072.0) AS DECIMAL(10,2)) AS [Free Space GB],
			CAST((SUM(version_store_reserved_page_count)/131072.0) AS DECIMAL(10,2)) AS [Version Store Space GB],
			CAST((SUM(user_object_reserved_page_count)/131072.0) AS DECIMAL(10,2)) AS [User Object Space GB],
			CAST((SUM(internal_object_reserved_page_count)/131072.0) AS DECIMAL(10,2)) AS [Internal Object Space GB]
		FROM tempdb.sys.dm_db_file_space_usage ;
		
	--  Shows the [current request only] usage of Tempdb by Session
	SELECT TOP 5 'Current Use' AS [Report Type], * 
		FROM (
			SELECT session_id AS [Session ID],  
					SUM(user_objects_alloc_page_count) - SUM(user_objects_dealloc_page_count) AS [User Objects Page Count] ,
					CAST((SUM(user_objects_alloc_page_count) - SUM(user_objects_dealloc_page_count)) / 131072.0 AS DECIMAL(10,2)) AS [User GB],
					SUM(internal_objects_alloc_page_count) - SUM(internal_objects_dealloc_page_count) AS [Internal Objects Page Count] ,
					CAST((SUM(internal_objects_alloc_page_count) - SUM(internal_objects_dealloc_page_count)) / 131072.0 AS DECIMAL(10,2)) AS [Internal GB]
				FROM tempdb.sys.dm_db_task_space_usage 
			GROUP BY session_id
			HAVING (SUM(internal_objects_alloc_page_count) - SUM(internal_objects_dealloc_page_count) > 0)
				OR (SUM(user_objects_alloc_page_count) - SUM(user_objects_dealloc_page_count) > 0)) AS [SessionCounts]
	ORDER BY [User GB] + [Internal GB] DESC ;


	--  Shows historical tempdb space usage by session. May not reflect current operation.
	SELECT TOP 10 'Historical Use' AS [Report Type], 
			session_id AS [Session ID], 
			(SELECT CASE WHEN es.login_name = '' THEN es.original_login_name
					 ELSE es.login_name END 
				FROM sys.dm_exec_sessions AS es 
			WHERE es.session_id = su.session_id) AS [Login Name],
			database_id AS [Database ID],
			CAST((user_objects_alloc_page_count/131072.0) AS DECIMAL(10,2)) - CAST(((user_objects_dealloc_page_count + user_objects_deferred_dealloc_page_count) /131072.0) AS DECIMAL(10,2)) AS [Current User Space GB],
			CAST((internal_objects_alloc_page_count/131072.0) AS DECIMAL(10,2)) - CAST((internal_objects_dealloc_page_count/131072.0) AS DECIMAL(10,2)) AS [Current Int Space GB],
			CAST((user_objects_alloc_page_count/131072.0) AS DECIMAL(10,2)) AS [User Allocated GB],
			CAST((user_objects_dealloc_page_count/131072.0) AS DECIMAL(10,2)) AS [User DeAllocated GB],
			CAST((user_objects_deferred_dealloc_page_count/131072.0) AS DECIMAL(10,2)) AS [Deferred DeAllocated GB],
			CAST((internal_objects_alloc_page_count/131072.0) AS DECIMAL(10,2)) AS [Internal Allocated GB],
			CAST((internal_objects_dealloc_page_count/131072.0) AS DECIMAL(10,2)) AS [Internal DeAllocated GB]
		FROM tempdb.sys.dm_db_session_space_usage AS su
	ORDER BY ((user_objects_alloc_page_count - (user_objects_dealloc_page_count + user_objects_deferred_dealloc_page_count)) + (internal_objects_alloc_page_count - internal_objects_dealloc_page_count)) DESC ;

END
