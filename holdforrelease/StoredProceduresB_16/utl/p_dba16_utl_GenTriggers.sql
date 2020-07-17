SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- ======================================================================================
-- p_dba16_utl_GenTriggers
--
-- Arguments:	@trigger_type
--				1) i or I: for trigger type - insert
--				2) u or U: for trigger type - update
--
-- CallS:		None
-- Called BY:	None
--
-- Description:	This procedure generates triggers - insert AND update for each table
--				in a database where this script exists.
--				1) This script is effective only in the database where it is
--				   installed.
--
--				2) The trigers named as follows:
--					insert - ti_name (where 'name' is the name of the trigger)
--					update - tu_name (where 'name' is the name of the trigger)
-- 
-- Date			Modified By			Changes
-- 08/11/2006   Aron E. Tekulsky    Initial Coding.
-- 11/22/2017   Aron E. Tekulsky    Update to Version 140.
-- ======================================================================================
--	Copyright©2001 - 2025 Aron Tekulsky.  World wide rights reserved.
--	Use of this code is free of charge but does not in any way imply transfer of 
--	Copyright ownership to the user.
-- ======================================================================================
--
CREATE PROCEDURE p_dba16_utl_GenTriggers 
	-- Add the parameters for the stored procedure here
	@trigger_type char(1) = ''
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets FROM
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
--
-- Local variables.
--
	DECLARE @table_name		varchar(50)
	DECLARE @trigger_action varchar(10)
	DECLARE @trigger_prefix char(3)
--
-- Validate input parameter: database.
--

--if not exists (
--	select *
--	FROM master.dbo.sysdatabases
--	where name = @database_name
--)
--BEGIN
--	PRINT 'ERROR: Invalid database name specified: ' + @database_name
--	PRINT '	Choose FROM the following databases:'
--	select name
--	FROM master.dbo.sysdatabases
--	order by name
--	return
--END

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
-- Get all the tables
--
	DECLARE Table_Cursor CURSOR FOR
		SELECT name 
			FROM sysobjects
		WHERE type = 'U'
		ORDER BY name ASC;

	OPEN Table_Cursor;

	FETCH NEXT FROM Table_Cursor
		INTO @table_name;

	WHILE @@FETCH_STATUS = 0
		BEGIN
--
--		BUILD Statement: if trigger exists then drop the trigger.
--
--		PRINT 'USE ' + @database_name
--		PRINT 'GO'
--		PRINT ''
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
		PRINT '	-- ''SET NOCOUNT ON'' added to prevent extra result sets FROM interfering with SELECT statements.'
		PRINT '	--'
		PRINT '	SET NOCOUNT ON;'
		PRINT ''
		PRINT '	--'
		PRINT '	-- Place insert statements for trigger here.'
		PRINT '	--'
		PRINT '	UPDATE dbo.' + @table_name 
		PRINT '		SET sql_id = user_id(),' 
		PRINT '			last_modified_date = getdate()'

		IF @trigger_type = 'i' OR @trigger_type = 'I'
			BEGIN
				PRINT '			creation_date = getdate()'
				PRINT '			lkp_row_status = ''A'''
			END

		PRINT '		FROM inserted i'
		PRINT '			JOIN ams_fund f ON (i.fund_id = f.fund_id)'
		--------PRINT '		WHERE i.fund_id = f.fund_id'
		PRINT 'END'
		PRINT 'GO'
		PRINT ''

--
--		Get the next table name.
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

	SET NOCOUNT OFF

	IF @@ERROR <> 0 GOTO ErrorHANDler

		RETURN 1

	ErrorHANDler:
		RETURN -1 
END
GO
GRANT EXECUTE ON p_dba16_utl_GenTriggers TO [db_proc_exec] AS [dbo]
GO
