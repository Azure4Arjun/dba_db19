USE [dba_db19]
GO

/****** Object:  StoredProcedure [dbo].[p_dba19_idx_GetSqlRowCountsByIndex]    Script Date: 7/27/2016 10:14:41 AM ******/
DROP PROCEDURE [dbo].[p_dba19_idx_GetSqlRowCountsByIndex]
GO

/****** Object:  StoredProcedure [dbo].[p_dba19_idx_GetSqlRowCountsByIndex]    Script Date: 7/27/2016 10:14:41 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


-- ==============================================================================
-- p_dba19_idx_GetSqlRowCountsByIndex
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
-- 07/26/2016	Aron E. Tekulsky	Add schema.
-- 07/27/2016	Aron E. Tekulsky	change to memory table.
-- 07/27/2019	Aron E. Tekulsky	Update to v140.
-- 05/19/2020	Aron E. Tekulsky	Update to v150.
-- ===============================================================================
--	Copyright©2001 - 2019 Aron Tekulsky.  World wide rights reserved.
--	Use of this code is free of charge but does not in any way imply transfer of 
--	Copyright ownership to the user.
-- ===============================================================================
CREATE PROCEDURE [dbo].[p_dba19_idx_GetSqlRowCountsByIndex] 
	-- Add the parameters for the stored procedure here
	@server_name	nvarchar(128)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED

	DECLARE @dbname	nvarchar(128)
	DECLARE	@cmd	nvarchar(4000)

	DECLARE @rc_temp TABLE(
		server_name	varchar(128)	null,
		db_nam		varchar(128)	null,
		schema_name	nvarchar(max)	null,
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
			SET @cmd = 'USE [' + @dbname + ']' +
			--'INSERT dba_db08.dbo.rc_temp (server_name, db_nam, obj_name, rc_nt, rws )' +
			--SET @cmd = 
			--'(server_name, db_nam, obj_name, rc_nt, rws )' +
			'SELECT ' + '''' + @server_name + '''' + ',' + '''' +  @dbname + '''' + ',OBJECT_SCHEMA_NAME(id) as SchemaNam , object_name(id) AS tname ,rowcnt, rows 
				FROM [' + @dbname + '].sys.sysindexes 
			WHERE indid IN (1,0) AND OBJECTPROPERTY(id,' +  '''' + 'IsUserTable' +'''' + ') = 1 AND
			rowcnt > 0
			ORDER BY tname ASC;';

			INSERT @rc_temp
			--dba_db08.dbo.rc_temp 
				EXEC (@cmd);

			PRINT @cmd;

			FETCH NEXT FROM db_cur INTO
				@dbname;

		END

		CLOSE db_cur;
		DEALLOCATE db_cur;

		SELECT server_name, [db_nam], [schema_name], [obj_name], [rc_nt], [rws]
			FROM @rc_temp
		ORDER BY server_name, db_nam, [schema_name], obj_name ASC;
END








GO


