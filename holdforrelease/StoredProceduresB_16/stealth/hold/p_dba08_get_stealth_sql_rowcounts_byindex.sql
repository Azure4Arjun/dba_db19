USE [dba_db08]
GO

/****** Object:  StoredProcedure [dbo].[p_dba08_get_stealth_sql_rowcounts_byindex]    Script Date: 6/3/2016 2:22:30 PM ******/
DROP PROCEDURE [dbo].[p_dba08_get_stealth_sql_rowcounts_byindex]
GO

/****** Object:  StoredProcedure [dbo].[p_dba08_get_stealth_sql_rowcounts_byindex]    Script Date: 6/3/2016 2:22:30 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO




-- ==============================================================================
-- p_dba08_get_stealth_sql_rowcounts_byindex
--
-- Arguments:		@server_name
--					None
--
-- Called BY:		None
-- Calls:			None
--
-- Description:	Get rowcounts for all tables in all databses
--				on a server. 
-- 
-- Date			Modified By			Changes
-- 05/03/2012   Aron E. Tekulsky    Initial Coding.
-- 07/31/2012	Aron E. Tekulsky	Add use stmt.
-- 04/19/2012	Aron E. Tekulsky	Update to v100.
-- ===============================================================================
--	Copyright©2009 - 2012 Aron Tekulsky.  World wide rights reserved.
--	Use of this code is free of charge but does not in any way imply transfer of 
--	Copyright ownership to the user.
-- ===============================================================================
CREATE PROCEDURE [dbo].[p_dba08_get_stealth_sql_rowcounts_byindex] 
	-- Add the parameters for the stored procedure here
	@server_name	nvarchar(128)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	DECLARE @dbname	nvarchar(128)
	DECLARE	@cmd	nvarchar(4000)

	--CREATE TABLE #@rc_temp (
	--	server_name	varchar(128)	null,
	--	db_nam		varchar(128)	null,
	--	obj_name	varchar(128)	null,
	--	rc_nt		bigint			null,
	--	rws			int				null)

	SET @cmd = '
	DECLARE db_cur CURSOR FOR
		SELECT d.name
			FROM [' + @server_name + '].sys.databases d
		WHERE d.state = 0 AND
				database_id > 4; '

	EXEC (@cmd);

	OPEN db_cur;

	FETCH NEXT FROM db_cur INTO
		@dbname;

	WHILE (@@fetch_status = 0)
		BEGIN
			--SET @cmd = 'USE [' + @dbname + ']' +
			--'INSERT dba_db08.dbo.rc_temp (server_name, db_nam, obj_name, rc_nt, rws )' +
			SET @cmd = 
			--'(server_name, db_nam, obj_name, rc_nt, rws )' +
			'SELECT ' + '''' + @server_name + '''' + ',' + '''' +  @dbname + '''' + ',object_name(id) AS tname ,rowcnt, rows 
				FROM [' +  @server_name + '].[' + @dbname + '].sys.sysindexes 
			WHERE indid IN (1,0) AND OBJECTPROPERTY(id,' +  '''' + 'IsUserTable' +'''' + ') = 1 AND
			rowcnt > 0
			ORDER BY tname ASC;'

			INSERT dba_db08.dbo.rc_temp 
				EXEC (@cmd);

			PRINT @cmd;

			FETCH NEXT FROM db_cur INTO
				@dbname;

		END

		CLOSE db_cur;
		DEALLOCATE db_cur;

		SELECT *
		FROM rc_temp
		ORDER BY server_name, db_nam, obj_name ASC
END




GO


