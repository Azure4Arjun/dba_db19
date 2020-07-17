SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- ======================================================================================
-- dba16_dig_ListDBSpaceInfoAK
--
--
-- Calls:		None
--
-- Description:	List DB space info
-- 
--	Practical Monitoring of Tempdb - Andrew Kelly - SQL Saturday Philadelphia 2019
--
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

	DECLARE @DBName			NVARCHAR(128) 
	DECLARE @ShowFileInfo	TINYINT = 0
	DECLARE @SQL			NVARCHAR(MAX) = '';

	IF @DBName IS NULL
		SET @DBName = DB_NAME() ;

	SET @SQL = N'USE [' + @DBName + '] ;' ;

	SET @SQL = @SQL + N'
		DECLARE @Tables TABLE ([DB Name] VARCHAR(128),[Object ID] INT, [Schema Name] VARCHAR(128), [Table Name] VARCHAR(128), [Row Count] BIGINT, 
                        [Reserved MB] BIGINT, [Data MB] BIGINT, [Index MB] BIGINT, [Unused MB] BIGINT ) ;

		DECLARE @DBCC TABLE ([Database Name] NVARCHAR(128),[Log Size(MB)] Decimal(10,4),[Log Space Used(%)] Decimal(10,4),[Status] INT) ;

		DECLARE @DataMaxSize BIGINT, @DataCurrentSize BIGINT, @UsedSpace BIGINT, @LogSize DECIMAL(10,2), @LogSpaceUsed DECIMAL(10,2) ;

		DECLARE @LogMaxSize BIGINT, @LogCurrentSize BIGINT ;

		-- Populate the table variable with the table info 
		INSERT INTO @Tables ([DB Name], [Object ID], [Schema Name], [Table Name], [Row Count], 
                    [Reserved MB], [Data MB], [Index MB], [Unused MB])
			SELECT 
					DB_NAME() AS [DB Name],
					a2.object_id,
					a3.name AS [schemaname],
					a2.name AS [tablename],
					a1.rows as row_count,
					((a1.[reserved] + ISNULL(a4.[reserved],0))* 8) / 1024 AS [reserved],
					(a1.[data] * 8) / 1024 AS [data],
					((CASE WHEN (a1.used + ISNULL(a4.used,0)) > a1.[data] THEN (a1.used + ISNULL(a4.used,0)) - a1.[data] 
								ELSE 0 END) * 8) / 1024 AS [index_size],
					((CASE WHEN (a1.[reserved] + ISNULL(a4.[reserved],0)) > a1.used THEN (a1.[reserved] + ISNULL(a4.[reserved],0)) - a1.used 
								ELSE 0 END) * 8) / 1024 AS [unused]
				FROM
					(SELECT ps.object_id, SUM (CASE WHEN (ps.index_id < 2) THEN row_count ELSE 0 END ) AS [rows],
							SUM (ps.reserved_page_count) AS [reserved], SUM (CASE WHEN (ps.index_id < 2) THEN (ps.in_row_data_page_count + ps.lob_used_page_count + ps.row_overflow_used_page_count)
								ELSE (ps.lob_used_page_count + ps.row_overflow_used_page_count) END ) AS [data],
							SUM (ps.used_page_count) AS [used]
						FROM sys.dm_db_partition_stats AS [ps]
					GROUP BY ps.object_id) AS [a1]
					LEFT OUTER JOIN
						(SELECT it.parent_id, SUM(ps.reserved_page_count) AS [reserved], SUM(ps.used_page_count) AS used
							FROM sys.dm_db_partition_stats AS ps 
								INNER JOIN sys.internal_tables it ON (it.object_id = ps.object_id)
						WHERE it.internal_type IN (202,204)
						GROUP BY it.parent_id) AS a4 ON (a4.parent_id = a1.object_id)
					INNER JOIN sys.all_objects AS a2  ON ( a1.object_id = a2.object_id )
					INNER JOIN sys.schemas AS a3 ON (a2.schema_id = a3.schema_id)
			WHERE a2.type <> N''S'' and a2.type <> N''IT'' ;


		SELECT t.[DB Name] AS [Database Name]
				, t.[Schema Name]
				, t.[Table Name]
				, t.[Row Count] AS [Row Count]
				, t.[Reserved MB] AS [Reserved MB]
				, t.[Data MB] AS [Data MB]
				, t.[Index MB] AS [Index MB]
				, (SELECT o.create_date 
						FROM sys.objects AS o 
					WHERE o.object_id = t.[Object ID]) AS [Create Date]
				, (SELECT o.modify_date 
						FROM sys.objects AS o 
					WHERE o.object_id = t.[Object ID]) AS [Modified Date]
			FROM @Tables AS t
		ORDER BY CAST([Reserved MB] AS BIGINT) DESC ;

	IF @ShowFileInfo = 1
		BEGIN

			SELECT @DataCurrentSize = SUM(CAST([size] AS BIGINT)) * 8 /1024 
					 ,@DataMaxSize =  SUM(CAST([max_size] AS BIGINT)) * 8 /1024 
				FROM sys.database_files AS df
			WHERE df.type = 0 ;
	
			SELECT @LogCurrentSize = SUM(CAST([size] AS BIGINT)) * 8 /1024 
					 ,@LogMaxSize =  SUM(CAST([max_size] AS BIGINT)) * 8 /1024 
				FROM sys.database_files AS df
			WHERE df.type = 1 ;

			SELECT @UsedSpace = SUM([Reserved MB]) FROM @Tables ;
    
		    INSERT INTO @DBCC EXEC(''DBCC SQLPERF(Logspace)'') ;

			SELECT @LogSize = [Log Size(MB)], @LogSpaceUsed = [Log Space Used(%)]
				FROM @DBCC 
			WHERE [Database Name] = DB_NAME(DB_ID()) ;

		    SELECT DB_NAME() AS [Database Name] 
				, @DataCurrentSize AS [Current DB Size MB]
				, CASE WHEN @DataMaxSize < 1 THEN ''Unlimited'' 
						ELSE CAST(@DataMaxSize AS VARCHAR(20)) 
				END AS [Max DB Size MB]
				, CASE WHEN @DataMaxSize < 1 THEN ''Unlimited'' 
						ELSE CAST(@DataMaxSize - @UsedSpace AS VARCHAR(20)) 
					END AS [Potential DB Free Space MB]
				, @LogSize AS [Tran Log Size MB]
				, @LogSpaceUsed AS [% Log Used]
				, CASE WHEN @LogMaxSize < 1 THEN ''Unlimited'' 
						ELSE CAST(@LogMaxSize AS VARCHAR(20)) 
					END AS [Max Log Size MB]
				, CASE WHEN @LogMaxSize < 1 THEN ''Unlimited'' 
						ELSE CAST(@LogMaxSize - @LogSpaceUsed AS VARCHAR(20)) 
					END AS [Potential Log Free Space MB];
END
'

	EXEC sp_executeSQL @statement = @SQL, @params = N'@ShowFileInfo TINYINT', @ShowfileInfo = @ShowfileInfo ;



END
