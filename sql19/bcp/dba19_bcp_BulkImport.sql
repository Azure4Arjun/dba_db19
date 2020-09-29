SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- ======================================================================================
-- dba19_bcp_BulkImport
--
--
-- Calls:		None
--
-- Description:	Bulk import data from a data file and format file.
-- 
-- Date			Modified By			Changes
-- 09/28/2020   Aron E. Tekulsky    Initial Coding.
-- 09/28/2020   Aron E. Tekulsky    Update to Version 150.
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

	DECLARE @Cmd				nvarchar(max)
	DECLARE @DataFileType		nvarchar(128)
	DECLARE @DBName				nvarchar(128)
	DECLARE @ErrorFileName		nvarchar(max)
	DECLARE @ErrorMsg			nvarchar(200)
	DECLARE @FieldTerminator	char(2) -- you must enter the terminator orit fails.
	DECLARE @RowTerminator		char(2) 
	DECLARE @SchemaName			nvarchar(128)
	DECLARE @SourceFileName		nvarchar(max)
	DECLARE @TableName			nvarchar(128)

	-- Inititialize
	SET @DataFileType		= 'char';
	SET @DBName				= 'test7';
	SET @ErrorFileName		= 'myerror.txt';
	SET @ErrorMsg			= '';
	SET @FieldTerminator	= '|';
	SET @SchemaName			= 'dbo';
	SET @SourceFileName		= 'mysource.txt';
	SET @TableName			= 'child1';
	SET @RowTerminator		= '\n';

	-- Clear the table.
	SET @Cmd = 'TRUNCATE TABLE [' + @DBName + '].[' + @SchemaName + '].[' + @TableName  + '] ;';

	EXEC( @Cmd);

	-- set up to do insert
	SET @Cmd = '
		BULK INSERT [' + @DBName + '].[' + @SchemaName + '].[' + @TableName  + '] ' + char(13) + 
			' FROM ' + '''' + @SourceFileName + '''' + 
			' WITH (
				DATAFILETYPE =   ' + '''' + @DataFileType + '''' + ',
				FIELDTERMINATOR = ' + '''' + @FieldTerminator + '''' + ',
				ROWTERMINATOR = ' + '''' + @RowTerminator + '''' + ',
				ERRORFILE = ' + '''' + @ErrorFileName + '''' + 
				' ); ';


	PRINT @Cmd;

	EXEC (@Cmd);

	SELECT @ErrorMsg = '[' + + @DBName + '].[' + @SchemaName + '].[' + @TableName  + '] Bulk Load: ' + 
		CAST(@@ROWCOUNT AS varchar(50)) + ' rows inserted ';
	RAISERROR (@ErrorMsg, 0, 1) WITH NOWAIT;


END
GO
