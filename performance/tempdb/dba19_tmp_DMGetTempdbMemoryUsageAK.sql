SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- ======================================================================================
-- dba19_tmp_DMGetTempdbMemoryUsageAK
--
--
-- Calls:		None
--
-- Description:	Get the tempdb memory usage.
-- 
--	Practical Monitoring of Tempdb - Andrew Kelly - SQL Saturday Philadelphia 2019
--
--	Note: requires VIEW SERVER STATE permissions.
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

	---  Tempdb Memory usage by SPID 
	USE tempdb ;

	--  May help identify queries waiting on memory grants
	--  Shows currently running tasks memory requests, grants and usage
	SELECT
			SPID = s.session_id,
			s.[host_name],
			s.[program_name],
			s.status,
			s.memory_usage,
			granted_memory = CONVERT(INT, r.granted_query_memory*8.00),
			t.text,
			sourcedb = DB_NAME(r.database_id),
			workdb = DB_NAME(dt.database_id),
			mg.*,
			su.*
		FROM sys.dm_exec_sessions AS s
			INNER JOIN sys.dm_db_session_space_usage AS su ON s.session_id = su.session_id AND 
																su.database_id = DB_ID('tempdb')
			INNER JOIN sys.dm_exec_connections AS c ON s.session_id = c.most_recent_session_id
			LEFT OUTER JOIN sys.dm_exec_requests AS r ON r.session_id = s.session_id
			LEFT OUTER JOIN
					(SELECT session_id, database_id
						FROM sys.dm_tran_session_transactions AS t
							INNER JOIN sys.dm_tran_database_transactions AS dt ON t.transaction_id = dt.transaction_id
					WHERE dt.database_id = DB_ID('tempdb')
					GROUP BY session_id, database_id) AS dt ON s.session_id = dt.session_id
			CROSS APPLY sys.dm_exec_sql_text(COALESCE(r.sql_handle, c.most_recent_sql_handle)) AS t
			LEFT OUTER JOIN sys.dm_exec_query_memory_grants AS mg ON s.session_id = mg.session_id
	WHERE (r.database_id = DB_ID('tempdb') OR dt.database_id = DB_ID('tempdb'))
	    AND s.status = 'running'
	ORDER BY SPID;



	--  Run GenTempLoads.sql first

	--  Database level Buffer Cache Breakdown
	SELECT --TOP 25 
			obj.[name],
			i.[name],
			i.[type_desc],
			count(*)AS Buffered_Page_Count ,
			count(*) * 8192 / (1024 * 1024) as Buffer_MB
			-- ,obj.name ,obj.index_id, i.[name]
		FROM sys.dm_os_buffer_descriptors AS bd 
			INNER JOIN 
				(
					SELECT object_name(object_id) AS name 
							,index_id ,allocation_unit_id, object_id
						FROM sys.allocation_units AS au
							INNER JOIN sys.partitions AS p ON au.container_id = p.hobt_id 
														AND (au.type = 1 OR au.type = 3)
					UNION ALL
					SELECT object_name(object_id) AS name   
							,index_id, allocation_unit_id, object_id
						FROM sys.allocation_units AS au
							INNER JOIN sys.partitions AS p ON au.container_id = p.hobt_id 
														AND au.type = 2) AS 
														obj ON bd.allocation_unit_id = obj.allocation_unit_id
			LEFT JOIN sys.indexes i on i.object_id = obj.object_id AND
									 i.index_id = obj.index_id
	WHERE database_id = db_id()
	GROUP BY obj.name, obj.index_id , i.[name],i.[type_desc]
	ORDER BY Buffered_Page_Count DESC;
	

END
GO
