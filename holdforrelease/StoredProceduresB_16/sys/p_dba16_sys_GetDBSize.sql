SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- ======================================================================================
-- p_dba16_sys_GetDBSize
--
-- Arguments:	None
--				None
--
-- CallS:		None
--
-- Called BY:	None
--
-- Description:	Get a list of all databases and their sizes.
-- 
-- Date			Modified By			Changes
-- 07/26/2011   Aron E. Tekulsky	Initial Coding.
-- 04/02/2012	Aron E. Tekulsky	add code to be sql 2008 compliant.
-- 03/04/2018   Aron E. Tekulsky   	Update to Version 140.
-- ======================================================================================
--	Copyright©2001 - 2025 Aron Tekulsky.  World wide rights reserved.
--	Use of this code is free of charge but does not in any way imply transfer of 
--	Copyright ownership to the user.
-- ======================================================================================
--
CREATE PROCEDURE p_dba16_sys_GetDBSize
	-- Add the parameters for the stored procedure here
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	CREATE TABLE #dbsize(
		dbname		varchar(50),
		dbid		smallint,
		tablename	sysname,
		tableid		int,
		rowlen		int,
		rowcnts		int)

	DECLARE @Cmd		nvarchar(4000)
	DECLARE @dbname		varchar(50)
	DECLARE @dbid		smallint
	DECLARE @dbstatus	int
	DECLARE @ObjType	Char(1)
	------DECLARE @dbstatus2	int
	------DECLARE @aron3 		varchar(100)
	------DECLARE @aron2 		varchar(400)
	------DECLARE	@aron 		varchar(200)
	DECLARE @tablename	sysname

-- get the database name
	DECLARE dbname_cur CURSOR FOR
		SELECT name, database_id, state--status, status2
			FROM sys.databases
		WHERE lower(name) NOT IN ('master','model','msdb','northwind','pubs','spotlight_logs','tempdb') AND
		      state = 0;

	OPEN dbname_cur;

	FETCH NEXT FROM dbname_cur 
		INTO @dbname, @dbid, @dbstatus--, @dbstatus2;

	WHILE (@@fetch_status <> -1)
		BEGIN
			IF (@@fetch_status <> -2)
				BEGIN
--		PRINT 'add user defined code here'
					SET @ObjType = 'U';
		 
-- get the table names

					SET @Cmd = 'INSERT INTO #dbsize
						(dbname, dbid, tablename, tableid)' +
						' select ''' + @dbname + ''', ' + convert(varchar(20),@dbid) + ',tablename=name, id from ' + @dbname + 
						'..sysobjects where xtype = '''+ @ObjType + '''' + ' and substring(name,1,2) != ' + '''' + 'dt' +'''';

--print @aron2

-- load up the row count table
					EXEC (@Cmd);

-- update with the row sizes
					SET @Cmd = 'UPDATE #dbsize
							 SET rowlen = v.rowlength
								FROM ' +  @dbname +  '..v_dba16_sys_RowLength ' + 'v,
								#dbsize d
							WHERE d.tablename = v.name AND
									d.dbname = ' + '''' + @dbname + '''';

					EXEC (@Cmd);

--		eg.
					DECLARE @message varchar(100);

					SELECT @message = 'dbname is: ' + @dbname;

					PRINT @message;
				END

			FETCH NEXT FROM dbname_cur 
				INTO @dbname, @dbid, @dbstatus;--, @dbstatus2;
		END

/*
-- update with the row sizes
set @aron2 = 'UPDATE #dbsize
		 SET rowlen = v.rowlength
	             FROM ' + '''' + @dbname + '''' + '.v_rowlength ' + 'v,
			#dbsize d
		WHERE d.tablename = v.name AND
		d.dbname = ' + '''' + @dbname + ''''

EXEC (@aron2)
*/
-- update with rowcounts

	CLOSE dbname_cur;
	DEALLOCATE dbname_cur;

-- declare cursor to get dbname and table name
	DECLARE dbtab_cur CURSOR FOR
		SELECT dbname, tablename
			FROM #dbsize;

-- open cursor
	OPEN dbtab_cur;

-- fetch first row
	FETCH NEXT FROM dbtab_cur 
		INTO @dbname, @tablename;

	WHILE (@@fetch_status <> -1)
		BEGIN
			IF (@@fetch_status <> -2)
				BEGIN

					set @Cmd = 'UPDATE #dbsize
						SET rowcnts = (
							SELECT count(*) 
								FROM ' + @dbname + '..' + @tablename + ')' + 
							'WHERE tablename = ' + '''' + @tablename + '''' + ' AND ' + 
									'dbname = ' + '''' + @dbname + '''';

		
					EXEC (@Cmd);
				END

			FETCH NEXT FROM dbtab_cur 
				INTO @dbname, @tablename;
		END


	CLOSE dbtab_cur;
	DEALLOCATE dbtab_cur

	select * from #dbsize;


	DROP TABLE #dbsize;

	IF @@ERROR <> 0 GOTO ErrorHandler;

	RETURN 1

	ErrorHandler:
	RETURN -1 
END
GO
--GRANT EXECUTE ON p_dba16_sys_GetDBSizeTO [db_proc_exec] AS [dbo]
--GO
