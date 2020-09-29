SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- ======================================================================================
-- dba19_sec_GetOrphanedUserids
--
--
-- Calls:		None
--
-- Description:	
-- 
-- Date			Modified By			Changes
-- 06/13/2012   Aron E. Tekulsky    Initial Coding.
-- 10/25/2017   Aron E. Tekulsky    Update to Version 140.
-- 08/25/2020   Aron E. Tekulsky    Update to Version 150.
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

	DECLARE @cmd		nvarchar(4000)
	DECLARE @dbname		nvarchar(128)
	DECLARE @username	varchar(25)
	DECLARE @orphan_db	nvarchar(128)

	CREATE TABLE #temp
	 (dbnam				nvarchar(128),
		orphanuser		varchar(25))


	DECLARE db_cur CURSOR FOR
		SELECT name
			FROM sys.databases
		WHERE state = 0 AND
			database_id > 4  AND
			name NOT IN ('dba_db');

	OPEN db_cur;

	FETCH NEXT FROM db_cur 
		INTO @dbname;

	WHILE @@FETCH_STATUS = 0
		BEGIN

		-- right join has no login
		SET @cmd =
			'INSERT INTO #temp
			SELECT ' + '''' + @dbname + '''' + ' AS dbnam, 
						u.name AS uname
				FROM sys.syslogins l
					RIGHT JOIN ' + @dbname + '.sys.sysusers u on (u.sid = l.sid)
			WHERE u.altuid IS NULL AND
				l.name IS NULL AND
				u.uid > 4 AND
				u.name <> ''dbo''  '

				print @cmd

				EXEC (@cmd);

		--print @dbname
			FETCH NEXT FROM db_cur 
				INTO @dbname;
		END

	CLOSE db_cur;
	 
	DEALLOCATE db_cur;


	SELECT dbnam, orphanuser
		FROM #temp;

	-- now we are ready to drop the user form the databases

------	-- declare the cursor
------	DECLARE check_orphan CURSOR FOR
------		SELECT orphanuser, dbnam
------		  FROM #temp;

-------- open the cursor
------	OPEN check_orphan;

-------- fetch the first row
------	FETCH NEXT FROM check_orphan
------		 INTO @username, @orphan_db;

------	WHILE @@FETCH_STATUS = 0
------		BEGIN

------			IF @username<>'dbo'
---------- remove dbo status form orphaned user
--------				EXEC sp_changedbowner 'sa'
------			--ELSE
-------- drop orphaned user
------				SET @cmd = 'EXEC ' + @orphan_db + '.sys.sp_dropuser ' + @username;

------				EXEC (@cmd);

------				print @cmd
------			Print 'deleting user ' +@username+ ' from database ' + @orphan_db

-------- fetch the next row
------			FETCH NEXT FROM check_orphan
------				 INTO @username, @orphan_db;

------		END

	DROP TABLE #temp;

	------CLOSE check_orphan;
	------DEALLOCATE check_orphan;

END
GO
