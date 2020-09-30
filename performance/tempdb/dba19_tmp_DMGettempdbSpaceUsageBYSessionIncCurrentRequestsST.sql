SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- ======================================================================================
-- dba19_tmp_DMGettempdbSpaceUsageBYSessionIncCurrentRequestsST
--
--
-- Calls:		None
--
-- Description:	get space usage by session including the current requests
--
-- https://www.mssqltips.com/sqlservertip/4356/track-sql-server-tempdb-space-usage/
-- 
-- Date			Modified By			Changes
-- 12/05/2018	Aron E. Tekulsky	Initial Coding.
-- 05/14/2019   Aron E. Tekulsky    Update to Version 140.
-- 08/13/2020   Aron E. Tekulsky    Update to Version 150.
-- ======================================================================================
--	Copyright�2001 - 2025 Aron Tekulsky.  World wide rights reserved.
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

	SELECT COALESCE(T1.session_id, T2.session_id) [session_id]
			,T1.request_id
			,COALESCE(T1.database_id, T2.database_id) [database_id]
			,COALESCE(T1.[Total Allocation User Objects], 0) + T2.[Total Allocation User Objects] [Total Allocation User Objects]
			,COALESCE(T1.[Net Allocation User Objects], 0) + T2.[Net Allocation User Objects] [Net Allocation User Objects]
			,COALESCE(T1.[Total Allocation Internal Objects], 0) + T2.[Total Allocation Internal Objects] [Total Allocation Internal Objects]
			,COALESCE(T1.[Net Allocation Internal Objects], 0) + T2.[Net Allocation Internal Objects] [Net Allocation Internal Objects]
			,COALESCE(T1.[Total Allocation], 0) + T2.[Total Allocation] [Total Allocation]
			,COALESCE(T1.[Net Allocation], 0) + T2.[Net Allocation] [Net Allocation]
			,COALESCE(T1.[Query Text], T2.[Query Text]) [Query Text]
		FROM (
			SELECT TS.session_id
					,TS.request_id
					,TS.database_id
					,CAST(TS.user_objects_alloc_page_count / 128 AS DECIMAL(15, 2)) [Total Allocation User Objects]
					,CAST((TS.user_objects_alloc_page_count - TS.user_objects_dealloc_page_count) / 128 AS DECIMAL(15, 2)) [Net Allocation User Objects]
					,CAST(TS.internal_objects_alloc_page_count / 128 AS DECIMAL(15, 2)) [Total Allocation Internal Objects]
					,CAST((TS.internal_objects_alloc_page_count - TS.internal_objects_dealloc_page_count) / 128 AS DECIMAL(15, 2)) [Net Allocation Internal Objects]
					,CAST((TS.user_objects_alloc_page_count + internal_objects_alloc_page_count) / 128 AS DECIMAL(15, 2)) [Total Allocation]
					,CAST((TS.user_objects_alloc_page_count + TS.internal_objects_alloc_page_count - TS.internal_objects_dealloc_page_count - TS.user_objects_dealloc_page_count) / 128 AS DECIMAL(15, 2)) [Net Allocation]
					,T.TEXT [Query Text]
				FROM sys.dm_db_task_space_usage TS
					INNER JOIN sys.dm_exec_requests ER ON ER.request_id = TS.request_id
														AND ER.session_id = TS.session_id
					OUTER APPLY sys.dm_exec_sql_text(ER.sql_handle) T
			) T1
			RIGHT JOIN (
				SELECT SS.session_id
						,SS.database_id
						,CAST(SS.user_objects_alloc_page_count / 128 AS DECIMAL(15, 2)) [Total Allocation User Objects]
						,CAST((SS.user_objects_alloc_page_count - SS.user_objects_dealloc_page_count) / 128 AS DECIMAL(15, 2)) [Net Allocation User Objects]
						,CAST(SS.internal_objects_alloc_page_count / 128 AS DECIMAL(15, 2)) [Total Allocation Internal Objects]
						,CAST((SS.internal_objects_alloc_page_count - SS.internal_objects_dealloc_page_count) / 128 AS DECIMAL(15, 2)) [Net Allocation Internal Objects]
						,CAST((SS.user_objects_alloc_page_count + internal_objects_alloc_page_count) / 128 AS DECIMAL(15, 2)) [Total Allocation]
						,CAST((SS.user_objects_alloc_page_count + SS.internal_objects_alloc_page_count - SS.internal_objects_dealloc_page_count - SS.user_objects_dealloc_page_count) / 128 AS DECIMAL(15, 2)) [Net Allocation]
						,T.TEXT [Query Text]
					FROM sys.dm_db_session_space_usage SS
						LEFT JOIN sys.dm_exec_connections CN ON CN.session_id = SS.session_id
						OUTER APPLY sys.dm_exec_sql_text(CN.most_recent_sql_handle) T
				) T2 ON T1.session_id = T2.session_id;

END
GO
