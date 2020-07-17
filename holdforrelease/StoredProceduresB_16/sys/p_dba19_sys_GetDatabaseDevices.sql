SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- ======================================================================================
-- p_dba19_sys_GetDatabaseDevices
--
-- Arguments:	None
--				None
--
-- CallS:		None
--
-- Called BY:	None
--
-- Description:	Get database devices.
-- 
-- Date			Modified By			Changes
-- 12/05/2002   Aron E. Tekulsky	Initial Coding.
-- 04/04/2012	Aron E. Tekulsky	Update to v100.
-- 03/23/2018   Aron E. Tekulsky    Update to Version 140.
-- 05/26/2020   Aron E. Tekulsky    Update to Version 150.
-- ======================================================================================
--	Copyright©2001 - 2025 Aron Tekulsky.  World wide rights reserved.
--	Use of this code is free of charge but does not in any way imply transfer of 
--	Copyright ownership to the user.
-- ======================================================================================
--
CREATE PROCEDURE p_dba19_sys_GetDatabaseDevices 
	-- Add the parameters for the stored procedure here
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;

	DECLARE @name			varchar(50),
			@dbid			smallint,
			@status			int,
			@status2		int,
			@crdate			datetime,
			@sql_select		nvarchar(1000)

-- creat a temp table to store all information
	CREATE TABLE #dev_listing
		(dbname nvarchar(128),
		 fileid smallint,
		logical nchar(128),
		filename nchar(260))

-- first get the database names
-- declare the cursor
	DECLARE db_cur CURSOR FOR
		SELECT name, database_id, state, create_date
			 FROM sys.databases;

-- open th cursor
	OPEN db_cur;

-- fetch the initial row
	FETCH NEXT FROM db_cur 
		INTO @name, @dbid, @status, @crdate;

-- loop through the rows.

	WHILE @@fetch_status = 0
		BEGIN
    -- create the table's fully qualified name
			SELECT @sql_select = 'INSERT INTO #dev_listing SELECT ' + '''' + @name + '''' + 
					   '  as dbname , file_id, name as logical, physical_name FROM ' + @name + '.sys.master_files';

    -- get the devices for the db
			EXEC sp_sqlexec @sql_select;


--        PRINT @sql_select
--        PRINT @name  + ' ' + convert(char,@@fetch_status)
-- then look up the devices for it.

			FETCH NEXT FROM db_cur 
				INTO @name, @dbid, @status, @crdate;
		END

    CLOSE db_cur;

    DEALLOCATE db_cur;

	SELECT dbname, fileid,logical,filename
		FROM #dev_listing;
    
    DROP TABLE #dev_listing;

	IF @@ERROR <> 0 GOTO ErrorHandler

	RETURN 1

	ErrorHandler:
	RETURN -1 
END
GO
GRANT EXECUTE ON p_dba19_sys_GetDatabaseDevices TO [db_proc_exec] AS [dbo]
GO
