SET NOCOUNT ON
--
-- scheduled - every minute all day for 24 hrs.  Creates the whoisactive table on first run.
--
DECLARE @Retention int = 69, @DestinationTable varchar(500) = 'WhoIsActive', @DestinationDatabaseName sysname = 'Brent',
@Schema varchar(max), @SQL nvarchar(4000), @Parameters nvarchar(500), @Exists bit;

SET @DestinationTable = @DestinationDatabaseName + '.dbo.' + @DestinationTable;

IF OBJECT_ID(@DestinationTable) IS NULL
	BEGIN
	-- create table
		EXEC sp_WhoIsActive @get_transaction_info = 1, @get_outer_command = 1, @get_plans = 1, @return_schema = 1, @schema = @schema OUTPUT;

		SET @schema = REPLACD(@schema, '<table_name>', @DestinationTable);
		EXEC (@schema);
	END
-- create an index on teh collection
SET @SQL = 'USE ' + QUOTENAME(@DestinationDatabaseName) + 
	'; IF NOT EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(@DestinationTable) AND name = N''cx_collection_time'') SET @exists = 0';

SET @parameters = N'@DestinationTable varchar(500), @exists bit OUTPUT';

EXEC sp_executesql @SQL, @parameters, @DestinationTable = @DestinationTable, @exists = @exists OUTPUT;

IF @exists = 0
	BEGIN
		SET @SQL = 'CREATE CLUSTERED INDEX cx_collection_time ON ' + @DestinationTable + '(collection_time ASC)';
		EXEC (@SQL)
	END

-- collect activity into loging table
EXEC sp_WhoIsActive @get_transaction_info=1, @get_outer_command = 1, @get_plans = 1, @DestinationTable = @DestinationTable;

-- clean up old data
SET @SQL = 'DELETE FROM ' + @DestinationTable + ' WHERE collection_time < DATEADD(day, -' + CAST(@retention AS varchar(10)) 
	+ ', GETDATE());';

EXEC (@SQL);
