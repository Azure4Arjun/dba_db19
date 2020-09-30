SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- ======================================================================================
-- dba_db16_agt_CreateSpWhoIsActiveBO
--
--
-- Calls:		None
--
-- Description:	Get sp_WhoisActive information.  Create storage table if it doesnt exist.
-- 
-- https://www.brentozar.com/responder/log-sp_whoisactive-to-a-table/
--
-- Date			Modified By			Changes
-- 02/21/2020   Aron E. Tekulsky    Initial Coding.
-- 02/21/2020   Aron E. Tekulsky    Update to Version 150.
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
	SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;


	DECLARE @retention INT = 7,
			@destination_table VARCHAR(500) = 'WhoIsActive',
			@destination_database sysname = 'Crap',
			@schema VARCHAR(MAX),
			@SQL NVARCHAR(4000),
			@parameters NVARCHAR(500),
			@exists BIT;

	SET @destination_table = @destination_database + '.dbo.' + @destination_table;

	--create the logging table
	IF OBJECT_ID(@destination_table) IS NULL
		BEGIN;
			EXEC dbo.sp_WhoIsActive @get_transaction_info = 1,
									@get_outer_command = 1,
									@get_plans = 1,
									@return_schema = 1,
									@schema = @schema OUTPUT;
			SET @schema = REPLACE(@schema, '<table_name>', @destination_table);
			EXEC ( @schema );
		END;

	--create index on collection_time
	SET @SQL
		= 'USE ' + QUOTENAME(@destination_database)
		  + '; IF NOT EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(@destination_table) AND name = N''cx_collection_time'') SET @exists = 0';
	SET @parameters = N'@destination_table varchar(500), @exists bit OUTPUT';
	EXEC sys.sp_executesql @SQL, @parameters, @destination_table = @destination_table, @exists = @exists OUTPUT;

	IF @exists = 0
		BEGIN;
			SET @SQL = 'CREATE CLUSTERED INDEX cx_collection_time ON ' + @destination_table + '(collection_time ASC)';
			EXEC ( @SQL );
		END;

	--collect activity into logging table
	EXEC dbo.sp_WhoIsActive @get_transaction_info = 1,
							@get_outer_command = 1,
							@get_plans = 1,
							@destination_table = @destination_table;

	--purge older data
	SET @SQL
		= 'DELETE FROM ' + @destination_table + ' WHERE collection_time < DATEADD(day, -' + CAST(@retention AS VARCHAR(10))
		  + ', GETDATE());';
	EXEC ( @SQL );
END
GO
