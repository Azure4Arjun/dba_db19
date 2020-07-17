--select type, COUNT(*)
--from sys.objects
--where type = 'P'
--group by type

--select *
--from sys.objects
--where type = 'P' and
--substring(name ,1,2) <> 'sp'


DECLARE @dbname			sysname,
		@sql_cmd		nvarchar(1000),
		@return_value	int

DECLARE db_cur CURSOR FOR
	SELECT m.name
	FROM master.dbo.sysdatabases m
	where m.dbid > 4 ;--and
	--m.state = 0;
	--where m.database_id > 4;

OPEN db_cur;

FETCH NEXT FROM db_cur 
	INTO @dbname;
	
WHILE (@@FETCH_STATUS = 0)
--WHILE (@@FETCH_STATUS <> -1)
	BEGIN
	
	--SET @sql_cmd = 'USE ' + @dbname + ';';
	
	--EXEC @return_value = @sql_cmd;
	
	--PRINT '**** ' + @dbname + ' ****'
	
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
		
		print @sql_cmd
			EXEC (@sql_cmd);

	FETCH NEXT FROM db_cur 
		INTO @dbname;

END

CLOSE db_cur
DEALLOCATE db_cur
