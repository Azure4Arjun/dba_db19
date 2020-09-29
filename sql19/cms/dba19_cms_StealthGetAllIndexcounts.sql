SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- ======================================================================================
-- dba19_cms_StealthGetAllIndexcounts
--
--
-- Calls:		None
--
-- Description:	Get a list of each index in each database and the counts.
-- 
-- Date			Modified By			Changes
-- 06/14/2012   Aron E. Tekulsky    Initial Coding.
-- 06/19/2012	Aron E. Tekulsky	Update to Version 100.
-- 01/03/2018   Aron E. Tekulsky    Update to Version 140.
-- 08/21/2020   Aron E. Tekulsky    Update to Version 150.
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

	DECLARE @dbname	nvarchar(128)
	DECLARE @cmd	nvarchar(4000)
	

	DECLARE @temp TABLE (		
			--[servnam]	[nvarchar](128) NULL,
			[dbnam]		[nvarchar](128) NULL,
			[tablnam]	[nvarchar](255) NULL,
			[idxcnt]	[int] NULL);

	--DECLARE db_cur CURSOR FOR
	--	SELECT name
	--		FROM sys.databases
	--	WHERE state = 0 AND
	--		database_id > 4 AND
	--		name not in (''Analysis Services Repository''); -- online NOT IN (''dba_db'');

	SET @CMD = ''
	DECLARE db_cur CURSOR FOR
		SELECT name
			--FROM ['' + @servername + ''].master.sys.databases
			FROM master.sys.databases
		WHERE state = 0 AND
			database_id > 4 AND
			name not in ( '''' + 'Analysis Services Repository' + '''' ); -- online '

	PRINT @CMD;

	EXEC(@CMD);


	OPEN db_cur;

	FETCH NEXT FROM db_cur 
		INTO @dbname;

	WHILE (@@FETCH_STATUS = 0)
		BEGIN

-- do the insert
		SET @cmd = 
				--''SELECT '' + '''''''' + @servername + '''''''' + '', '' +  '''''''' + @dbname + '''''''' + ''AS dbnam, o.name AS tablename,  count(i.index_id) AS indexcnt
				'SELECT  ' +  '''' + @dbname + '''' + 'AS dbnam, o.name AS tablename,  count(i.index_id) AS indexcnt
					FROM [' + @dbname + '].sys.indexes i
					--FROM ['' + @servername + ''].['' + @dbname + ''].sys.indexes i
						LEFT JOIN [' + @dbname + '].sys.objects o on (o.object_id = i.object_id)
						--LEFT JOIN ['' + @servername + ''].['' + @dbname + ''].sys.objects o on (o.object_id = i.object_id)
					WHERE o.type = ' + '''' + 'U' + '''' + 
					' GROUP BY  o.name
					HAVING count(i.index_id) > 0';
			

				print @cmd;

				INSERT INTO @temp
					EXEC (@cmd);
				
		--print @dbname
			FETCH NEXT FROM db_cur 
				INTO @dbname;
		END

	CLOSE db_cur;
	 
	DEALLOCATE db_cur;


	SELECT --servnam, 
		dbnam, tablnam, idxcnt, CASE 	
									WHEN idxcnt > 5 THEN '*** DANGER ***'
									END AS idxstatus
		FROM @temp
	ORDER BY dbnam ASC, tablnam ASC;
	--ORDER BY servnam ASC, dbnam ASC, tablnam ASC;



	IF @@ERROR <> 0 GOTO ErrorHandler

	--RETURN 1

	ErrorHandler:
	--RETURN -1 

END
GO
