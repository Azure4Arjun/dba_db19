SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- ======================================================================================
-- dba16_sys_GetSqlRowCountsByIndex
--
--
-- Calls:		None
--
-- Description:	Get rowcounts for all tables in all databses
--				on a server. 
-- 
-- Date			Modified By			Changes
-- 05/03/2012   Aron E. Tekulsky    Initial Coding.
-- 07/31/2012	Aron E. Tekulsky	Add use stmt.
-- 04/19/2012	Aron E. Tekulsky	Update to v100.
-- 01/02/2018   Aron E. Tekulsky    Update to V140.
-- ======================================================================================
--	Copyright©2001 - 2025 Aron Tekulsky.  World wide rights reserved.
--	Use of this code is free of charge but does not in any way imply transfer of 
--	Copyright ownership to the user.
-- ======================================================================================
--
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	DECLARE	@cmd	nvarchar(4000)
	DECLARE @dbname	nvarchar(128)

	CREATE TABLE #@rc_temp (
		--server_name	varchar(128)	null,
		db_nam		varchar(128)	null,
		obj_name	varchar(128)	null,
		rc_nt		bigint			null,
		rws			int				null)

	DECLARE db_cur CURSOR FOR
		SELECT d.name
			FROM sys.databases d
		WHERE d.state = 0 AND
				database_id > 4; -- and
				--database_id < 25; -- online

	OPEN db_cur;

	FETCH NEXT FROM db_cur INTO
		@dbname;

	WHILE (@@fetch_status = 0)
		BEGIN
			--SET @cmd = 'USE [' + @dbname + ']' +
			--'INSERT dba_db08.dbo.rc_temp (server_name, db_nam, obj_name, rc_nt, rws )' +
			SET @cmd = 
			--'(server_name, db_nam, obj_name, rc_nt, rws )' +
			'SELECT ' + '''' +  @dbname + '''' + ' AS DBName,object_name(id) AS tname ,rowcnt, rows 
				FROM [' + @dbname + '].sys.sysindexes 
			WHERE indid IN (1,0) AND OBJECTPROPERTY(id,' +  '''' + 'IsUserTable' +'''' + ') = 1 AND
			rowcnt > 0
			ORDER BY tname ASC;'

			INSERT #@rc_temp 
				EXEC (@cmd);

			PRINT @cmd;

			FETCH NEXT FROM db_cur INTO
				@dbname;

		END

		CLOSE db_cur;
		DEALLOCATE db_cur;

		SELECT *
		FROM #@rc_temp
		ORDER BY  db_nam, obj_name ASC

END
GO
