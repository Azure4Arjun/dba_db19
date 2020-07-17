SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- ======================================================================================
-- dba16_sys_GetCompressionEstimate
--
--
-- Calls:		None
--
-- Description:	To estimate compression.
--
-- https://codingsight.com/overview-of-data-compression-in-sql-server/
--
-- Date			Modified By			Changes
-- 12/06/2018	Initial Coding.
-- 04/15/2019	Aron E. Tekulsky
-- 05/17/2019   Aron E. Tekulsky    Update to Version 140.
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
	------------DECLARE DB_CUR CURSOR FOR
	------------ SELECT Name--,state_desc Status
	------------ FROM sys.databases
	------------ WHERE name NOT IN ('master', 'model', 'msdb', 'tempdb','OSSDBADB' )
	------------ AND state_desc = 'ONLINE'
	------------ ------AND is_read_only <> 1 --means DATABASE = IN READ ONLY mode

	------------ --AND CHARINDEX('-',name) = 0
	--AND-- no dashes in dbname
	------------
	--[dba_db08].[dbo].[f_dba14_get_dbrole] (name) = 1
	------------ ORDER BY NAME ASC;

	DECLARE TABL_CUR CURSOR FOR
		SELECT [TABLE_SCHEMA], [TABLE_NAME]
			FROM [INFORMATION_SCHEMA].[TABLES]
		WHERE [TABLE_TYPE] = 'BASE TABLE';

	-- *** Set the compression type to use ***
	SET @CompressionType = 'PAGE';
	
	SET @DBName = DB_NAME();

	----'AgileAutomationDatabase';
	OPEN TABL_CUR;

	FETCH NEXT FROM TABL_CUR
		INTO @SchemaName, @TablName;

	------------OPEN DB_CUR;
	------------FETCH NEXT FROM DB_CUR
	------------ INTO @DBName;
	----PRINT @TablName
	----PRINT @SchemaName
	----PRINT @@FETCH_STATUS

	WHILE (@@FETCH_STATUS <> - 1)
		BEGIN
			SET @Cmd = 'USE [' + @DBName + ']
				' + 'EXEC sp_estimate_data_compression_savings
				@schema_name = ' + '''' + @SchemaName + '''' + ',
				@object_name = ' + '''' + @TablName + '''' + ',
				@index_id = NULL,
				@partition_number = NULL,
				@data_compression = ' + '''' + @CompressionType + '''' + ';';

		----PRINT @Cmd;
	
			INSERT INTO @CompEstimate
				EXEC (@Cmd);

			FETCH NEXT FROM TABL_CUR
				INTO 
					@SchemaName, @TablName;

		--------FETCH NEXT FROM DB_CUR
		-------- INTO @DBName;
		END

	CLOSE TABL_CUR;

	DEALLOCATE TABL_CUR;

	------------CLOSE DB_CUR;
	------------DEALLOCATE DB_CUR;

	SELECT @DBName AS DBName
			,schema_name
			,e.object_name
			,e.index_id
			,e.partition_number
			,e.size_with_current_compression_setting AS CurrentSize
			,e.size_with_requested_compression_setting AS CompressedSize
			,e.sample_size_with_current_compression_setting AS CurrentSampleSize
			,e.sample_size_with_requested_compression_setting AS CompressedSampleSize
		FROM @CompEstimate e
	ORDER BY e.schema_name ASC, e.object_name ASC, e.index_id ASC;



END
GO
