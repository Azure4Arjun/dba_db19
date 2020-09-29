SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- ======================================================================================
-- dba19_sys_GetMoveAllUserdb
--
--
-- Calls:		None
--
-- Description:	Reset assigned devices for user db and set up for move to another 
--				physical loaction.
-- 
-- Date			Modified By			Changes
-- 01/01/2012   Aron E. Tekulsky    Initial Coding.
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

	DECLARE 
		@cmd			nvarchar(4000),
		@cmd2			nvarchar(4000),
		@dbid			smallint,
		@filename		nvarchar(128),
		@loopcount		tinyint,
		@logical_name	nvarchar(128),
		@MaxFileId		int,
		@name			varchar(50),
		@newdatapath	nvarchar(4000),
		@newlogpath		nvarchar(4000),
		@Type			tinyint
		

	DECLARE @dbdevice TABLE (
		rc				int,
		dbname			nvarchar(128),
		fileid			int,
		type			tinyint,
		logical			nvarchar(128),
		physical_name	nvarchar(260),
		filename		nvarchar(128))
	
	DECLARE db_cur CURSOR FOR
		SELECT name, database_id
		   FROM sys.databases
		 WHERE state = 0 AND
				database_id > 4;-- AND
				----name = 'test7'; -- on-line

-- initialize
	SET @MaxFileId = 0;
	SET @loopcount = 1;

-- open th cursor
	OPEN db_cur;

-- fetch the initial row
	FETCH NEXT FROM db_cur 
		INTO @name, @dbid;

	SET @newdatapath = 'c:\Program Files\Microsoft SQL Server\MSSQL.1\MSSQL\Data'
	SET @newlogpath = 'c:\Program Files\Microsoft SQL Server\MSSQL.1\MSSQL\Log'

-- loop through the rows.

	WHILE (@@fetch_status = 0)
		BEGIN
		
			-- re-initialize @MaxFileId
			SET @MaxFileId = 0;

			PRINT 'Step 1 - take the DB off line'
	
			SET @cmd = 'ALTER DATABASE [' +  @name +  '] SET OFFLINE;'
		
			PRINT @cmd
		
			PRINT 'Step 2 - move the physical datbase files to the new location'
		
			PRINT 'Step 3 - run commands to change db file locations for data and log in the Master db'
		
			SET @cmd2 = 'SELECT 0,' + '''' + @name + '''' +    '  as dbname , file_id, type, name as logical, physical_name,
								dba_db16.dbo.f_dba16_sys_RemoveAllBackSlashes(physical_name) as filename' + --',0' +
					' FROM [' + @name + '].sys.master_files '  +
				'WHERE database_id = convert(smallint,' + '''' + convert(varchar(10),@dbid) + '''' + ')' +
				' ORDER BY type ASC, file_id ASC;';
		
		------PRINT 'the select is ' + @cmd2
	
		
			INSERT INTO @dbdevice
				EXEC (@cmd2);
			
-- get the loop count for number of devices
			SELECT @MaxFileId = MAX (fileid)
								FROM @dbdevice
							WHERE dbname = @name;

			------PRINT 'max id = '  + convert(varchar(20),@MaxFileId);

			SET @loopcount = 1;

			WHILE (@loopcount <= @MaxFileId)
				BEGIN

					SET @Type = (SELECT type 
										FROM @dbdevice 
									WHERE dbname = @name AND
										fileid = @loopcount);

					SET	@filename = (SELECT filename 
										FROM @dbdevice 
									WHERE dbname = @name AND
										fileid = @loopcount);
									
					SET @logical_name = (SELECT logical 
										FROM @dbdevice 
									WHERE dbname = @name AND
										fileid = @loopcount);


										------PRINT 'logical is ' + @logical_name;
		
					------IF @loopcount = 1					
					IF @Type = 0 -- Rows				
							SET @cmd = 'ALTER DATABASE [' + @name + '] MODIFY FILE ( NAME = ' + @logical_name + ', FILENAME = ' + '''' + 
										@newdatapath + '\'  + @filename + '''' + ' );';
						ELSE -- Log
							SET @cmd = 'ALTER DATABASE [' + @name + '] MODIFY FILE ( NAME = ' + @logical_name + ', FILENAME = ' + '''' + 
									@newlogpath + '\'  + @filename + '''' + ' );';

					PRINT @cmd
		
		-- increment the loop counter
					SET @loopcount = @loopcount + 1;
				END

			PRINT ' Step 4 - put the db back on-line'

			SET @cmd = 'ALTER DATABASE [' +  @name +  '] SET ONLINE;'
		
			PRINT @cmd
			PRINT ''
			PRINT ''
			
-- fetch the initial row
		FETCH NEXT FROM db_cur 
			INTO @name, @dbid;

		END
	
	CLOSE db_cur;
	DEALLOCATE db_cur;
	
	SELECT *
		FROM @dbdevice;
		
	
END
GO
