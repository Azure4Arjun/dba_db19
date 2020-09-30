SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- ======================================================================================
-- dba19_cmp_GetCompressionEstimateAllDBCI
--
--
-- Calls:		None
--
-- Description:	To estimate compression on all db on the server..
--
-- https://codingsight.com/overview-of-data-compression-in-sql-server/
-- 
-- Date			Modified By			Changes
-- 12/06/2018	Aron E. Tekulsky	Initial Coding.
-- 04/15/2019	Aron E. Tekulsky
-- 05/17/2019   Aron E. Tekulsky    Update to Version 140.
-- 08/05/2019	Aron E. Tekulsky	Add columns for mb, gb, & tb.
-- 08/12/2020   Aron E. Tekulsky    Update to Version 150.
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

--WARNING! ERRORS ENCOUNTERED DURING SQL PARSING!
	DECLARE @Cmd										NVARCHAR(4000)
	DECLARE @CompressionType							VARCHAR(4)
	DECLARE @DBName										NVARCHAR(128)
	DECLARE @SchemaName									NVARCHAR(128)
	DECLARE @TablName									NVARCHAR(128)
	
	DECLARE @CompEstimate TABLE (
		object_name										NVARCHAR(128)
		,schema_name									NVARCHAR(128)
		,index_id										INT
		,partition_number								INT
		,size_with_current_compression_setting			INT
		,size_with_requested_compression_setting		INT
		,sample_size_with_current_compression_setting	INT
		,sample_size_with_requested_compression_setting	INT
		)

	DECLARE TABL_CUR CURSOR FOR
		SELECT [TABLE_SCHEMA], [TABLE_NAME]
			FROM [INFORMATION_SCHEMA].[TABLES]
		WHERE [TABLE_TYPE] = 'BASE TABLE';

	-- *** Set the compression type to use ***
	SET @CompressionType = 'PAGE';

-- Declare the dbname variable.
					----------DECLARE @DBName	nvarchar(128)

		-- Declare the cursor.
	DECLARE db_cur CURSOR FOR
		SELECT Name--,state_desc Status
			FROM sys.databases
		WHERE name NOT IN ('master', 'model', 'msdb', 'tempdb','ReportServer','ReportServerTempDB','dba_db16','SSISDB')
			AND state_desc = 'ONLINE'
			AND is_read_only <> 1 --means database=in read only mode
			AND CHARINDEX('-',name) = 0 --AND-- no dashes in dbname
			--[dba_db08].[dbo].[f_dba14_get_dbrole] (name) = 1
		ORDER BY NAME ASC;
						
	-- Open the cursor.
	OPEN db_cur;

	-- Do the first fetch of the cursor.
	FETCH NEXT FROM db_cur INTO
				@DBName;

	SET @Cmd = 'USE [' + @DBName + '] ' + ' ;';

	EXEC (@Cmd);


	-- Set up the loop.
	WHILE (@@FETCH_STATUS <> -1)
		BEGIN
		--  place Code here --

		-- TABL_CUR code --
		-- TRUNCATE TABLE @CompEstimate;

			OPEN TABL_CUR;

			FETCH NEXT FROM TABL_CUR
				INTO @SchemaName, @TablName;


			WHILE (@@FETCH_STATUS <> - 1)
				BEGIN
					SET @Cmd = 'USE [' + @DBName + ']
						' + 'EXEC sp_estimate_data_compression_savings
						@schema_name = ' + '''' + @SchemaName + '''' + ',
						@object_name = ' + '''' + @TablName + '''' + ',
						@index_id = NULL,
						@partition_number = NULL,
						@data_compression = ' + '''' + @CompressionType + '''' + ';';

		PRINT @Cmd;
	
					INSERT INTO @CompEstimate
						EXEC (@Cmd);

					FETCH NEXT FROM TABL_CUR
						INTO 
							@SchemaName, @TablName;

				END

			CLOSE TABL_CUR;

			DEALLOCATE TABL_CUR;

			-- clean up memory optimized table.
			DELETE FROM
				@CompEstimate;


		-- END TABL_CUR code --
					
			FETCH NEXT FROM db_cur INTO
				@dbname;
		END

	-- Close the cursor.
	CLOSE db_cur;

	-- Deallocate the cursor.
	DEALLOCATE db_cur;

				


	
	----------SET @DBName = DB_NAME();



	------------CLOSE DB_CUR;
	------------DEALLOCATE DB_CUR;

	SELECT @DBName AS DBName
			,schema_name
			,e.object_name
			,e.index_id
			,e.partition_number
			,e.size_with_current_compression_setting AS CurrentSizeKB
			,e.size_with_requested_compression_setting AS CompressedSizeKB
			,e.size_with_current_compression_setting/1024 AS CurrentSizeMB
			,e.size_with_requested_compression_setting/1024 AS CompressedSizeMB
			,e.size_with_current_compression_setting/1024/1024 AS CurrentSizeGB
			,e.size_with_requested_compression_setting/1024/1024 AS CompressedSizeGB
			,e.size_with_current_compression_setting/1024/1024/1024 AS CurrentSizeTB
			,e.size_with_requested_compression_setting/1024/1024/1024 AS CompressedSizeTB
			,e.sample_size_with_current_compression_setting AS CurrentSampleSizeKB
			,e.sample_size_with_requested_compression_setting AS CompressedSampleSizeKB
		FROM @CompEstimate e
	ORDER BY e.schema_name ASC, e.object_name ASC, e.index_id ASC;


END
GO
