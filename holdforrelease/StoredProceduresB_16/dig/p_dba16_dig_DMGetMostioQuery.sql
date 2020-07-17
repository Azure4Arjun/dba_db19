SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- ======================================================================================
-- p_dba16_dig_DMGetMostioQuery
--
-- Arguments:	None
--				None
--
-- CallS:		None
--
-- Called BY:	None
--
-- Description:	Get the queries with the most IO
-- 
-- Date			Modified By			Changes
-- 07/26/2011   Aron E. Tekulsky    Initial Coding.
-- 01/17/2012	Aron E. Tekulsky	add insert into temp table fo better output.
-- 04/03/2012	Aron E. Tekulsky	Update to v100.
-- 07/12/2016	Aron E. Tekulsky	increase currentdb to 1000
-- 07/12/2016	Aron E. Tekulsky	Add memory table.
-- 02/08/2018   Aron E. Tekulsky    Update to Version 140.
-- ======================================================================================
--	Copyright©2001 - 2025 Aron Tekulsky.  World wide rights reserved.
--	Use of this code is free of charge but does not in any way imply transfer of 
--	Copyright ownership to the user.
-- ======================================================================================
--
CREATE PROCEDURE p_dba16_dig_DMGetMostioQuery 
	-- Add the parameters for the stored procedure here
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
    DECLARE @CurrentDatabase		nvarchar(1000),
			@cmd					nvarchar(4000),
			@database_id			int,
			@state_desc				nvarchar(1000)


	DECLARE @mostqio TABLE (
			[m_dbid]				[int] NULL,
			[m_average_IO]			[bigint] NULL,
			[m_total_IO]			[bigint] NULL,
			[m_execution_count]		[bigint] NULL,
			[m_individual_query]	[nvarchar](2000) NULL,
			[m_object_name]			[varchar](1000) NULL,
			[m_database_name]		[varchar](1000) NULL)

    DECLARE db_cur CURSOR FOR
			SELECT Name,state_desc Status, database_id
				FROM sys.databases
			WHERE name NOT IN ('master', 'model', 'msdb', 'tempdb', 'QuestWorkDatabase', 'dba_db08')
				AND state_desc = 'ONLINE'
			order by database_id asc --name asc

	OPEN db_cur;
		
	FETCH NEXT FROM db_cur
			INTO @CurrentDatabase,@state_desc ,@database_id;
          
          
    WHILE (@@FETCH_STATUS <> -1)
		BEGIN
-- new code --
			INSERT @mostqio (
			m_dbid,
			m_average_IO,
			m_total_IO,
			m_execution_count,
			m_individual_query,
			m_object_name,
			m_database_name)
-- end new code --
			SELECT TOP 100 qt.dbid,
				(total_logical_reads + total_logical_writes) / qs.execution_count AS average_IO,
			    (total_logical_reads + total_logical_writes) AS total_IO,
				qs.execution_count AS execution_count,
				convert(nvarchar(2000),substring(SUBSTRING (qt.text,qs.statement_start_offset/2, 
					(CASE WHEN qs.statement_end_offset = -1 
						THEN LEN(CONVERT(NVARCHAR(MAX), qt.text)) * 2 
						ELSE qs.statement_end_offset END - qs.statement_start_offset)/2),1,255)) AS individual_query,
				o.name AS object_name,
				DB_NAME(qt.dbid) AS database_name
			FROM sys.dm_exec_query_stats qs
				CROSS APPLY sys.dm_exec_sql_text(qs.sql_handle) as qt
				LEFT OUTER JOIN sys.objects o ON qt.objectid = o.object_id 
				where DB_NAME(qt.dbid) = @CurrentDatabase
					 ORDER BY DB_NAME(qt.dbid) asc, average_IO DESC;

			--SET @cmd = 
			--'SELECT TOP 100 qt.dbid,
			--	(total_logical_reads + total_logical_writes) / qs.execution_count AS average_IO,
			--    (total_logical_reads + total_logical_writes) AS total_IO,
			--	qs.execution_count AS execution_count,
			--	SUBSTRING (qt.text,qs.statement_start_offset/2, 
			--		(CASE WHEN qs.statement_end_offset = -1 
			--			THEN LEN(CONVERT(NVARCHAR(MAX), qt.text)) * 2 
			--			ELSE qs.statement_end_offset END - qs.statement_start_offset)/2) AS individual_query,
			--	o.name AS object_name,
			--	DB_NAME(qt.dbid) AS database_name
			--FROM sys.dm_exec_query_stats qs
			--	CROSS APPLY sys.dm_exec_sql_text(qs.sql_handle) as qt
			--	LEFT OUTER JOIN sys.objects o ON qt.objectid = o.object_id 
			--		 ORDER BY DB_NAME(qt.dbid) asc, average_IO DESC;'
					 
			--	--where DB_NAME(qt.dbid) = ' + '''' + @CurrentDatabase + '''' +

			----print @cmd
			--EXEC (@cmd);


			--EXEC dba_db.dbo.p_dba08_dm_get_mostioquery_by_database @CurrentDatabase
			
			FETCH NEXT FROM db_cur
				INTO @CurrentDatabase,@state_desc ,@database_id;

		END

	CLOSE db_cur;
	DEALLOCATE db_cur;

	SELECT m_dbid,
			m_average_IO,
			m_total_IO,
			m_execution_count,
			m_individual_query,
			m_object_name,
			m_database_name
		FROM @mostqio
		
	--DROP TABLE ##mostqio

	IF @@ERROR <> 0 GOTO ErrorHandler

	RETURN 1

	ErrorHandler:
	RETURN -1 
END
GO

GRANT EXECUTE ON p_dba16_dig_DMGetMostioQuery TO [db_proc_exec] AS [dbo]
GO
