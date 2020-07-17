SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- ======================================================================================
-- p_dba16_utl_GenTriggersDB
--
-- Arguments:	@database_name
--				@trigger_type	
--				1) i or I: for trigger type - insert
--				2) u or U: for trigger type - update

--				None
--
-- CallS:		None
-- Called BY:	None
--
-- Description:	This procedure generates triggers - insert AND update for each table
--			in a database WHERE this script exists.
--					1) This script is effective only in the database WHERE it is
--					   installed.
--					2) The trigers named as follows:
--							insert - ti_name (WHERE 'name' is the name of the trigger)
--							update - tu_name (WHERE 'name' is the name of the trigger)
-- 
-- Date			ModIFied By			Changes
-- 08/11/2006   Aron E. Tekulsky    Initial Coding.
-- 11/22/2017   Aron E. Tekulsky    Update to Version 140.
-- ======================================================================================
--	Copyright©2001 - 2025 Aron Tekulsky.  World wide rights reserved.
--	Use of this code is free of charge but does NOT in any way imply transfer of 
--	Copyright ownership to the user.
-- ======================================================================================
--
CREATE PROCEDURE p_dba16_utl_GenTriggersDB 
	-- Add the parameters for the stored procedure here
	@database_name varchar(30),
	@trigger_type char(1)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets FROM
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
--
-- Local variables.
--
	DECLARE @SQLString		nvarchar(500);
	DECLARE @table_name		varchar(50)
	DECLARE @trigger_action varchar(10)
	DECLARE @trigger_prefix char(3)

--
-- Validate input parameter: database.
--
	IF NOT EXISTS (
		SELECT *
			FROM master.dbo.sysdatabases
		WHERE name = @database_name)

		BEGIN
			PRINT 'ERROR: Invalid database name specIFied: ' + @database_name
			PRINT '	Choose FROM the following databases:'
			SELECT name
				FROM master.dbo.sysdatabases
			ORDER BY name;

			RETURN
		END

--
-- Validate input parameter: trigger type.
--
	IF @trigger_type <> 'u' AND @trigger_type <> 'U' AND @trigger_type <> 'i' AND @trigger_type <> 'I'
		BEGIN
			PRINT 'Usage: exec GEN_Triggers [i, I, u, U]'
			PRINT ' i, I - for trigger type INSERT'
			PRINT ' u, U - for trigger type UPDATE'
			RETURN
	END


--
-- Initialize variables.
--
	IF @trigger_type = 'u' OR @trigger_type = 'U'
		BEGIN
			SELECT @trigger_prefix = 'tu_'
			SELECT @trigger_action = 'UPDATE'
		END
	ELSE
		BEGIN
			SELECT @trigger_prefix = 'ti_'
			SELECT @trigger_action = 'INSERT'
		END


--
-- Build the dynamic SQL statement based on the database.
--

-- Set column list. CHAR(13) is a carriage RETURN, line feed.--
	SET @SQLString = N'DECLARE Table_Cursor CURSOR FOR SELECT name ' + CHAR(13);

-- Set FROM clause with carriage RETURN, line feed. --
	SET @SQLString = @SQLString + N'FROM ' +  @database_name + '.dbo.sysobjects' + CHAR(13);

-- Set WHERE clause. --
	SET @SQLString = @SQLString + N'ORDER BY name';

--
-- Get all the tables
--
	EXEC sp_executesql @SQLString;

	OPEN Table_Cursor;

	FETCH NEXT FROM Table_Cursor
		INTO @table_name;

	WHILE (@@FETCH_STATUS = 0)
		BEGIN
	--
	-- BUILD Statement: IF trigger exists then drop the trigger.
	--
			PRINT 'USE ' + @database_name
			PRINT 'GO'
			PRINT ''
			PRINT '--'
			PRINT '-- ' + @trigger_action + ' TRIGGER - Table: ' + @table_name
			PRINT '--'
			PRINT 'IF EXISTS (SELECT * FROM sysobjects WHERE name = ''' + @trigger_prefix + @table_name + ''' AND type = ''TR'')'
			PRINT '	DROP TRIGGER ' + @trigger_prefix + @table_name
			PRINT 'GO'

			PRINT 'CREATE TRIGGER ' + @trigger_prefix + @table_name 
			PRINT '	ON dbo.' + @table_name 
			PRINT '	AFTER ' + @trigger_action
			PRINT 'AS'
			PRINT '	BEGIN'
			PRINT '	--'
			PRINT '	-- ''SET NOCOUNT ON'' added to prevent extra result sets from interfering with SELECT statements.'
			PRINT '	--'
			PRINT '	SET NOCOUNT ON;'
			PRINT ''
			PRINT '	--'
			PRINT '	-- Place insert statements for trigger here.'
			PRINT '	--'
			PRINT '	UPDATE dbo.' + @table_name 
			PRINT '		SET sql_id = user_id(),' 
			PRINT '			last_modIFied_date = getdate()'

			IF @trigger_type = 'i' or @trigger_type = 'I'
				BEGIN
					PRINT '			creation_date = getdate()'
					PRINT '			lkp_row_status = ''A'''
				END

			PRINT '		FROM inserted i, ams_fund f'
			PRINT '		WHERE i.fund_id = f.fund_id'
			PRINT 'END'
			PRINT 'GO'
			PRINT ''

	--
	-- Get the next table name.
	--
			FETCH NEXT FROM Table_Cursor
				INTO
					@table_name;
		END

--
-- Close AND deallocate cursor: Table_Cursor.
--
	CLOSE Table_Cursor;
	DEALLOCATE Table_Cursor;


	IF @@ERROR <> 0 GOTO ErrorHANDler

	RETURN 1

	ErrorHANDler:
	RETURN -1 
END
GO
GRANT EXECUTE ON p_dba16_utl_GenTriggersDB TO [db_proc_exec] AS [dbo]
GO
