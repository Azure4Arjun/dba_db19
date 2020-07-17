SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- ======================================================================================
-- p_dba16_idx_GetAllIndexCounts
--
-- Arguments:	None
--				None
--
-- CallS:		None
--
-- Called BY:	None
--
-- Description:	Get a list of each index in each database and the counts.
-- 
-- Date			Modified By			Changes
-- 06/14/2012   Aron E. Tekulsky    Initial Coding.
-- 06/19/2012	Aron E. Tekulsky	Update to v100.
-- 07/26/2016	Aron E. Tekulsky	use memory table. increase size of dbname.
--									Add schema name.
-- 03/18/2018   Aron E. Tekulsky    Update to Version 140.
-- ======================================================================================
--	Copyright©2001 - 2025 Aron Tekulsky.  World wide rights reserved.
--	Use of this code is free of charge but does not in any way imply transfer of 
--	Copyright ownership to the user.
-- ======================================================================================
--
CREATE PROCEDURE p_dba16_idx_GetAllIndexCounts 
	-- Add the parameters for the stored procedure here
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	DECLARE @cmd	nvarchar(4000)
	DECLARE @dbid	int
	DECLARE @dbname	nvarchar(4000)
	
	--CREATE TABLE #temp1
	--	(servnam		nvarchar(128),
	--	 dbnam			nvarchar(128),
	--	 tablnam		nvarchar(255),
	--	 idxcnt			int)

	DECLARE @temp1 TABLE (		
			[servnam]		[nvarchar](128) NULL,
			[dbnam]			[nvarchar](4000) NULL,
			[schemaname]	[nvarchar](4000) NULL,
			[tablnam]		[nvarchar](255) NULL,
			[idxcnt]		[int] NULL);

	DECLARE db_cur CURSOR FOR
		SELECT name, database_id
			FROM sys.databases
		WHERE state = 0 AND
			database_id > 4 AND
			name NOT IN ('Analysis Services Repository'); -- online NOT IN ('dba_db');

	OPEN db_cur;

	FETCH NEXT FROM db_cur 
		INTO @dbname, @dbid;

	WHILE (@@FETCH_STATUS = 0)
		BEGIN

		---- right join has no login
		--	--SET @cmd = 'INSERT INTO [@temp1]
		--		--SELECT ' + '''' + 'aron' + '''' + ', ' +  '''' + @dbname + '''' + 'AS dbnam, o.name AS tablename,  count(i.index_id) AS indexcnt
		--	SET @cmd = '
		--		SELECT ' + '''' + @@servername + '''' + ', ' +  '''' + @dbname + '''' + 'AS dbnam, o.name AS tablename,  count(i.index_id) AS indexcnt
		--			FROM [' + @dbname + '].sys.indexes i
		--				LEFT JOIN [' + @dbname + '].sys.objects o on (o.object_id = i.object_id)
		--			WHERE o.type = ' + '''' + 'U' + '''' + 
		--			' GROUP BY  o.name
		--			HAVING count(i.index_id) > 0';
			

		--				--LEFT JOIN ' + @dbname + '.sys.index_columns c on (c.object_id = i.object_id)
		--		print @cmd

		--		EXEC (@cmd)
-- do the insert
			--SET @cmd = 'INSERT INTO [@temp1]
					--(servnam, dbnam, tablnam, idxcnt)
					--SELECT ' + '''' + 'aron2' + '''' + ', ' +  '''' + @dbname + '''' + 'AS dbnam, o.name AS tablename,  count(i.index_id) AS indexcnt
		--SET @cmd = 'INSERT INTO temp
		SET @cmd = 'SELECT ' + '''' + @@servername + '''' + ', ' +  '''' + @dbname + '''' + 'AS dbnam,OBJECT_SCHEMA_NAME(i.object_id, CONVERT(int,' + '''' +  convert(nvarchar(100),@dbid)  + '''' + ')) as SchemaNam, o.name AS tablename,  count(i.index_id) AS indexcnt
					FROM [' + @dbname + '].sys.indexes i
						LEFT JOIN [' + @dbname + '].sys.objects o on (o.object_id = i.object_id)
					WHERE o.type = ' + '''' + 'U' + '''' + 
					' GROUP BY  i.object_id, o.name
					HAVING count(i.index_id) > 0';
			

						--LEFT JOIN ' + @dbname + '.sys.index_columns c on (c.object_id = i.object_id)
				print @cmd;

				INSERT INTO @temp1
					EXEC (@cmd);
				
		--print @dbname
			FETCH NEXT FROM db_cur 
				INTO @dbname, @dbid;
		END

	CLOSE db_cur;
	 
	DEALLOCATE db_cur;


	SELECT servnam, dbnam, schemaname, tablnam, idxcnt
		FROM @temp1
	ORDER BY servnam ASC, dbnam ASC, schemaname ASC, tablnam ASC;


	IF @@ERROR <> 0 GOTO ErrorHandler

	RETURN 1

	ErrorHandler:
	RETURN -1 
END
GO
GRANT EXECUTE ON p_dba16_idx_GetAllIndexCounts TO [db_proc_exec] AS [dbo]
GO
