SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- ======================================================================================
-- dba19_sys_EvaluateDBStatus
--
--
-- Calls:		None
--
-- Description:	
-- 
-- Date			Modified By			Changes
-- 01/23/2007   Aron E. Tekulsky    Initial Coding.
-- 05/15/2019   Aron E. Tekulsky    Update to Version 140.
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

	DECLARE @dbid				int
	DECLARE @descr_hold			varchar(100)
	DECLARE @hold				int
	DECLARE @name				sysname
	DECLARE @status				int
	DECLARE @status2			int
	DECLARE @stat_descr			varchar(100)
	DECLARE @stat_descr_hold	varchar(100)

	CREATE TABLE #dbs 
		(name					sysname not null,
		dbid					smallint not null,
		status					int not null,
		status2					int not null,
		stat_descr				varchar(100) null)

	INSERT INTO #dbs
			SELECT name, dbid, status, status2, ''
		FROM master.dbo.sysdatabases;
--where name = 'master'

	UPDATE #dbs
		SET stat_descr = b.dbstatus_description
			FROM #dbs a
				JOIN dba_db16..dbstatus_codes b ON (a.status = b.dbstatus_codes);
 

-- set up cursor

	DECLARE db_cur CURSOR FOR
		SELECT name, dbid, status, status2, stat_descr
			FROM #dbs
		WHERE stat_descr = '';
   --and name = 'msdb' -- temp for test

	OPEN db_cur;

	FETCH NEXT FROM db_cur 
		INTO 
			@name,@dbid, @status, @status2, @stat_descr;

	PRINT @@FETCH_status;

	WHILE (@@FETCH_status <> -1)

--	print @descr_hold +@stat_descr_hold +@hold


		BEGIN
--	select @hold = @status - 1073741824
			SELECT @hold = @status;

			IF @hold >= 1073741824
				BEGIN
					-- get the description
					SELECT @stat_descr_hold = dbstatus_description
						FROM dbstatus_codes
					WHERE dbstatus_codes = 1073741824;

					-- save the description
					SELECT @descr_hold = isnull(@descr_hold,'') + ', '+ @stat_descr_hold;

					-- reset the status value
					SELECT @hold = @hold - 1073741824;
    
				END

			-- check the NEXT number
			IF @hold >= 4194304 
				BEGIN
					SELECT @stat_descr_hold = dbstatus_description
						FROM dbstatus_codes
					WHERE dbstatus_codes = 4194304;

					SELECT @descr_hold = isnull(@descr_hold,'') + ', '+ @stat_descr_hold;

					SELECT @hold = @hold - 4194304;
				END

			-- check the NEXT number
			IF @hold >= 32768 
				BEGIN
					SELECT @stat_descr_hold = dbstatus_description
						FROM dbstatus_codes
					WHERE dbstatus_codes = 32768;

					SELECT @descr_hold = isnull(@descr_hold,'') + ', '+ @stat_descr_hold;

					SELECT @hold = @hold - 32768;
				END

			-- check the NEXT number
			IF @hold >= 4096 
				BEGIN
					SELECT @stat_descr_hold = dbstatus_description
						FROM dbstatus_codes
					WHERE dbstatus_codes = 4096;

					SELECT @descr_hold = isnull(@descr_hold,'') + ', '+ @stat_descr_hold;
				
					SELECT @hold = @hold - 4096;
				END


-- check the NEXT number
			IF @hold >= 2048 
				BEGIN
					SELECT @stat_descr_hold = dbstatus_description
						FROM dbstatus_codes
					WHERE dbstatus_codes = 2048;

					SELECT @descr_hold = isnull(@descr_hold,'') + ', '+ @stat_descr_hold;

					SELECT @hold = @hold - 2048;
				END

-- check the NEXT number
			IF @hold >= 1024 
				BEGIN
					SELECT @stat_descr_hold = dbstatus_description
						FROM dbstatus_codes
					WHERE dbstatus_codes = 1024;

					SELECT @descr_hold = isnull(@descr_hold,'') + ', '+ @stat_descr_hold;

					SELECT @hold = @hold - 1024;
				END

-- check the NEXT number
			IF @hold >= 512 
				BEGIN
					SELECT @stat_descr_hold = dbstatus_description
						FROM dbstatus_codes
					WHERE dbstatus_codes = 512;

					SELECT @descr_hold = isnull(@descr_hold,'') + ', '+ @stat_descr_hold;

					SELECT @hold = @hold - 512;
				END
	

-- check the NEXT number
			IF @hold >= 256 
				BEGIN
					SELECT @stat_descr_hold = dbstatus_description
						FROM dbstatus_codes
					WHERE dbstatus_codes = 256;

					SELECT @descr_hold = isnull(@descr_hold,'') + ', '+ @stat_descr_hold;

					SELECT @hold = @hold - 256;
				END


-- check the NEXT number
			IF @hold >= 128 
				BEGIN
					SELECT @stat_descr_hold = dbstatus_description
						FROM dbstatus_codes
					WHERE dbstatus_codes = 128;

					SELECT @descr_hold = isnull(@descr_hold,'') + ', '+ ', '+ @stat_descr_hold;

					SELECT @hold = @hold - 128;
			END


-- check the NEXT number
			IF @hold >= 64 
				BEGIN
					SELECT @stat_descr_hold = dbstatus_description
						FROM dbstatus_codes
					WHERE dbstatus_codes = 64;

					SELECT @descr_hold = isnull(@descr_hold,'') + ', '+ @stat_descr_hold;

					SELECT @hold = @hold - 64;
				END


-- check the NEXT number
			IF @hold >= 32 
				BEGIN
					SELECT @stat_descr_hold = dbstatus_description
						FROM dbstatus_codes
					WHERE dbstatus_codes = 32;

					SELECT @descr_hold = isnull(@descr_hold,'') + ', '+ @stat_descr_hold;

					SELECT @hold = @hold - 32;
				END

			PRINT @hold;

-- check the NEXT number
			IF @hold >= 16 
				BEGIN
					SELECT @stat_descr_hold = dbstatus_description
						FROM dbstatus_codes
					WHERE dbstatus_codes = 16;

					SELECT @descr_hold = isnull(@descr_hold,'') + ', '+ @stat_descr_hold;

					SELECT @hold = @hold - 16;
			END

			PRINT @hold;
			PRINT @descr_hold;
			PRINT @stat_descr_hold;

-- check the NEXT number
			IF @hold >= 8 
				BEGIN
					SELECT @stat_descr_hold = dbstatus_description
						FROM dbstatus_codes
					WHERE dbstatus_codes = 8;

					SELECT @descr_hold = isnull(@descr_hold,'') + ', '+ @stat_descr_hold;

					SELECT @hold = @hold - 8;
			END


-- check the NEXT number
			IF @hold >= 4 
				BEGIN
					SELECT @stat_descr_hold = dbstatus_description
						FROM dbstatus_codes
					WHERE dbstatus_codes = 4;

					SELECT @descr_hold = isnull(@descr_hold,'') + ', '+ @stat_descr_hold;

					SELECT @hold = @hold - 4;
			END


-- check the NEXT number
			IF @hold >= 1 
				BEGIN
					SELECT @stat_descr_hold = dbstatus_description
						FROM dbstatus_codes
					WHERE dbstatus_codes = 1;

					SELECT @descr_hold = isnull(@descr_hold,'') + ', '+@stat_descr_hold;

					SELECT @hold = @hold - 1;
				END

-- eliminate leading comma
			IF SUBSTRING(@descr_hold,1,1) = ','
				SELECT @descr_hold = SUBSTRING(@descr_hold,2,len(@descr_hold)-1);

-- do the UPDATE	
			UPDATE #dbs
				SET stat_descr = @descr_hold
					FROM #dbs a
				WHERE a.dbid = @dbid;

			FETCH NEXT FROM db_cur 
				INTO 
					@name,@dbid, @status, @status2, @stat_descr;

--initialize
			SELECT @descr_hold = '', @stat_descr_hold = '', @hold = 0;
		END


	SELECT * 
		FROM #dbs;

	DROP TABLE #dbs;

	CLOSE db_cur;

	DEALLOCATE db_cur;

END
GO
