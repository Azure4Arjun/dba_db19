SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- ======================================================================================
-- dba19_utl_GetInitialDBFileSize
--
--
-- Calls:		None
--
-- Description:	
-- 
-- https://www.sqlservercentral.com/forums/topic/initial-size-of-the-database-file-using-t-sql
--
-- Date			Modified By			Changes
-- 12/20/2019   Aron E. Tekulsky    Initial Coding.
-- 12/20/2019   Aron E. Tekulsky    Update to Version 150.
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
	SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;

	DECLARE @Cmd		nvarchar(4000)
	DECLARE @DBName		nvarchar(128)
	DECLARE @DBId		int
	DECLARE @RunFlag	tinyint

	DECLARE @Page0Dump table (
		ParentObject	nvarchar(4000), 
		Object			nvarchar(4000),
		Field			nvarchar(4000), 
		VALUE			nvarchar(4000),
		DBName			nvarchar(128));

	SET @RunFlag = 1; -- 0 all, 1 minsize

	DECLARE db_cur CURSOR FOR
		SELECT name, database_id
			FROM sys.databases
		WHERE name NOT IN ('master','model','msdb','tempdb','reportserver','reprotservertempdb','SSISDB')
			AND state_desc = 'ONLINE'
			AND is_read_only <> 1
			AND CHARINDEX('-',name) = 0
		ORDER BY name asc;

	OPEN db_cur;

	FETCH NEXT FROM db_cur INTO 
		@DBName, @DBId;

	------SET @Cmd = 'SELECT db_name(database_id) AS DBName, max(file_id) AS MaxFileId
	------				FROM sys.master_files
	------			WHERE databse_id = ' + CONVERT(varchar(10),@DBId) +
	------				' GROUP BY database_id';
	PRINT @Cmd;

	WHILE (@@FETCH_STATUS <>  -1)
		BEGIN

			SET @Cmd = N'DBCC PAGE (N' + '''' + @DBName + '''' + ', 1, 0, 3) with tableresults';

			PRINT @Cmd;

			INSERT INTO @Page0Dump (ParentObject, Object, Field, VALUE)
				EXEC sp_executesql @Cmd;

			UPDATE @Page0Dump 
				SET DBName = @DBName
			WHERE DBName IS NULL;

			FETCH NEXT FROM db_cur INTO 
				@DBName, @DBId;
		END

	CLOSE db_cur;
	DEALLOCATE db_cur;

	IF @RunFlag = 0
	-- all values
		SELECT p.DBName, p.ParentObject,  p.Object, p.Field, p.VALUE
			------Object, pd.[VALUE] * 8 [Initial Size (MB)] 
			FROM @Page0Dump p
		ORDER BY p.DBName ASC;
	ELSE
		-- Min file size
		SELECT p.DBName, p.ParentObject,  p.Object, p.Field, (p.VALUE * 8) AS InitialSizeMB
			------Object, pd.[VALUE] * 8 [Initial Size (MB)] 
			FROM @Page0Dump p
		WHERE p.Field = 'MinSize'
		ORDER BY p.DBName ASC;
END
GO
