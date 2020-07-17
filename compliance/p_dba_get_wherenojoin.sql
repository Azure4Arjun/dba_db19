USE [dba_db]
GO
/****** Object:  StoredProcedure [dbo].[p_dba_get_wherenojoin]    Script Date: 03/11/2009 11:58:32 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- =============================================================================
-- Author:		Aron E. Tekulsky
-- Create date: 03/11/09
-- Description:	Get a listing of objects not foiloowing ansi standards for join
--
--
--	03/11/2009	Aron E. Tekulsky	Initial coding.
--  07/19/2012	Aron E. Tekulsky	Make 2008 compiant.  Add sort by name and state = 0 for on-line.
-- =============================================================================
Alter PROCEDURE p_dba_get_wherenojoin
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

DECLARE @dbname			sysname,
		@sql_cmd		nvarchar(1000),
		@return_value	int

DECLARE db_cur CURSOR FOR
	SELECT m.name
		FROM sys.databases m
	WHERE m.database_id > 4 and
			m.state = 0
	ORDER BY m.name ASC;
	--where m.database_id > 4;

OPEN db_cur;

FETCH NEXT FROM db_cur 
	INTO @dbname;
	
WHILE (@@FETCH_STATUS = 0)
	BEGIN
	
--IF (SELECT [compatibility_level] FROM sys.databases WHERE database_id = DB_ID()) < 90
	IF CAST(LEFT(CAST(SERVERPROPERTY('ProductVersion') AS nvarchar(255)),CHARINDEX('.',CAST(SERVERPROPERTY('ProductVersion') AS nvarchar(255)))-1) + '.' + REPLACE(RIGHT(CAST(SERVERPROPERTY('ProductVersion') AS nvarchar(255)), LEN(CAST(SERVERPROPERTY('ProductVersion') AS nvarchar(255))) - CHARINDEX('.',CAST(SERVERPROPERTY('ProductVersion') AS nvarchar(255)))),'.','') AS numeric(18,9)) < 9
--.003042
	  BEGIN
-- 2000
		SET @sql_cmd =  'select ' + '''' + @dbname + '''' + 'as dbname8, o.name, o.type, o.id , c.status , c.text
		from ' + @dbname + '.dbo.sysobjects o
		join ' + @dbname + '.dbo.syscomments c on (c.id = o.id )
		where o.type = ' + '''' + 'P'+ '''' + ' and
		substring(o.name ,1,2) <> ' + '''' + 'sp' +'''' + ' and 
		upper(c.text) not like(' + '''' + '%JOIN%' + '''' + ') and
		upper(c.text) like (' + '''' + '%FROM%' + '''' + ') and
		upper(c.text) like (' + '''' + '%WHERE%' + '''' + ') ';
	  END
	ELSE
		BEGIN
------ if 2005 or 2008 use sys.
		SET @sql_cmd =  'select ' + '''' + @dbname + '''' + 'as dbname9, o.name, o.type, o.id , c.status , c.text
		from ' + @dbname + '.sys.sysobjects o
		join ' + @dbname + '.sys.syscomments c on (c.id = o.id )
		where o.type = ' + '''' + 'P'+ '''' + ' and 
		substring(o.name ,1,2) <> ' + '''' + 'sp' +'''' + ' and
		upper(c.text) not like(' + '''' + '%JOIN%' + '''' + ') and
		upper(c.text) like (' + '''' + '%FROM%' + '''' + ') and
		UPPER(c.text) like (' + '''' + '%WHERE%' + '''' + ') ';
	END
		
			EXEC (@sql_cmd);

	FETCH NEXT FROM db_cur 
		INTO @dbname;

END

CLOSE db_cur
DEALLOCATE db_cur

END



GO
GRANT EXECUTE ON [dbo].[p_dba_get_wherenojoin] TO [db_proc_exec] AS [dbo]