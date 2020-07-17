SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- ======================================================================================
-- p_dba19_mnt_GenerateSnapshot
--
-- Arguments:	None
--				None
--
-- CallS:		None
--
-- Called BY:	None
--
-- Description:	Create a databse snapshot
--
-- https://docs.microsoft.com/en-us/previous-versions/sql/sql-server-2012/ms175876(v=sql.110)?redirectedfrom=MSDN
-- 
-- Date			Modified By			Changes
-- 01/01/2020   Aron E. Tekulsky    Initial Coding.
-- 01/01/2020   Aron E. Tekulsky    Update to Version 140.
-- ======================================================================================
--	Copyright©2001 - 2025 Aron Tekulsky.  World wide rights reserved.
--	Use of this code is free of charge but does not in any way imply transfer of 
--	Copyright ownership to the user.
-- ======================================================================================
--
CREATE PROCEDURE p_dba19_mnt_GenerateSnapshot 
	-- Add the parameters for the stored procedure here
	@DataSourceDb	varchar(128),			-- this is the db to get snapshot of.
	@SnapshotAppend	varchar(128)	= NULL, -- item you  wnat to append to the snapshot.
	@FilePath		varchar(200)	= NULL,	-- new destination for snapshot.
	@FileSql		varchar(max)	= '',
	@Debug			bit				= 0
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;

	DECLARE @SnapSQL	nvarchar(max)

	SET @SnapshotAppend = ISNULL(@SnapshotAppend, 'Snap_' + FORMAT(CURRENT_TIMESTAMP,'yyyymmdd_hhmmss'))

	IF DB_ID(@DataSourceDb) IS NULL
		RAISERROR('Database does not exist. Pleae check spelling ans instance you are connected to.',1,1) WITH NOWAIT;

	-- set file path location
	IF @FilePath = ''
		SET @FilePath = NULL;

	-- Dynamic build list of db to be included in snapshot.
	SELECT @FileSql = @FileSql + 
		CASE 
			WHEN @FileSql <> ''
				THEN + cast(',' AS varchar(max))
			ELSE ''
			END + CAST ('
				( NAME + ' AS varchar(max)) + CAST(mf.name AS varchar(max)) + CAST(', FILENAME = ''' AS varchar(max)) +
					CAST(ISNULL(@FilePath, LEFT(mf.physical_name, LEN(mf.physical_name) -4) ) AS varchar(max)) 
					+ CAST('_' AS varchar(max)) + CAST(@SnapshotAppend AS varchar(max)) + CAST('.ss'')' AS varchar(max))
		FROM sys.master_files AS mf
			INNER JOIN sys.databases AS db ON (db.database_id = mf.database_id )
	WHERE db.state = 0 -- on line
		AND mf.type = 0 -- data file
		AND db.name = @DataSourceDb;

	-- next is #3 build snapshot syntax
	SET @SnapSQL = 
		'
		CREATE DATABASE ' + @DataSourceDb + '_' + @SnapshotAppend + '
			ON ' + @FileSql + ' AS SNAPSHOT OF ' + @DataSourceDb + ';';

	-- next is 4 print/execute
	IF (@Debug = 1) 
		PRINT @SnapSQL;
	ELSE
		EXEC sp_executesql @stmt = @SnapSQL;


	IF @@ERROR <> 0 GOTO ErrorHandler

	RETURN 1

	ErrorHandler:
	RETURN -1 
END
GO
GRANT EXECUTE ON p_dba19_mnt_GenerateSnapshot TO [db_proc_exec] AS [dbo]
GO
