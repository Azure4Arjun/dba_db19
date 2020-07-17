SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- ======================================================================================
-- p_dba16_stl_StealthGetSqlRowCountsByIndex
--
-- Arguments:	@server_name
--				None
--
-- CallS:		None
--
-- Called BY:	None
--
-- Description:	Get rowcounts for all tables in all databses
--				on a server. 
-- 
-- Date			Modified By			Changes
-- 05/03/2012   Aron E. Tekulsky    Initial Coding.
-- 07/31/2012	Aron E. Tekulsky	Add use stmt.
-- 04/19/2012	Aron E. Tekulsky	Update to v100.
-- 11/20/2019	Aron E. Tekulsky	update to v140.
-- ======================================================================================
--	Copyright©2001 - 2025 Aron Tekulsky.  World wide rights reserved.
--	Use of this code is free of charge but does not in any way imply transfer of 
--	Copyright ownership to the user.
-- ======================================================================================
--
CREATE PROCEDURE p_dba16_stl_StealthGetSqlRowCountsByIndex 
	-- Add the parameters for the stored procedure here
	@server_name nvarchar(128)  
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;

	DECLARE @dbname	nvarchar(128)
	DECLARE	@cmd	nvarchar(4000)

	DECLARE @rc_temp TABLE (
		[server_name]	varchar(128)	NULL,
		[db_nam]		varchar(128)	NULL,
		[obj_name]		varchar(128)	NULL,
		[rc_nt]			bigint			NULL,
		[rws]			int				NULL)

	SET @cmd = '
		DECLARE db_cur CURSOR FOR
			SELECT d.name
				FROM [' + @server_name + '].[master].[sys].[databases] d
			WHERE d.state = 0 AND
					database_id > 4; '

	EXEC (@cmd);

	OPEN db_cur;

	FETCH NEXT FROM db_cur INTO
		@dbname;

	WHILE (@@fetch_status = 0)
		BEGIN
			SET @cmd = 
				'SELECT ' + '''' + @server_name + '''' + ',' + '''' +  @dbname + '''' + ',object_name(id) AS tname ,rowcnt, rows 
					FROM [' +  @server_name + '].[' + @dbname + '].[sys].[sysindexes] 
				WHERE indid IN (1,0) AND OBJECTPROPERTY(id,' +  '''' + 'IsUserTable' +'''' + ') = 1 AND
					rowcnt > 0
				ORDER BY tname ASC;'

			INSERT @rc_temp 
				EXEC (@cmd);

			PRINT @cmd;

			FETCH NEXT FROM db_cur INTO
				@dbname;

		END

		CLOSE db_cur;
		DEALLOCATE db_cur;

		SELECT *
		FROM @rc_temp
		ORDER BY server_name, db_nam, obj_name ASC

	IF @@ERROR <> 0 GOTO ErrorHandler

	RETURN 1

	ErrorHandler:
	RETURN -1 
END
GO
GRANT EXECUTE ON p_dba16_stl_StealthGetSqlRowCountsByIndex TO [db_proc_exec] AS [dbo]
GO
