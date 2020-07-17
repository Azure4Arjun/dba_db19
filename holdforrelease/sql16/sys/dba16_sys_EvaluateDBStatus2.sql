SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- ======================================================================================
-- dba16_sys_EvaluateDBStatus2
--
--
-- Calls:		None
--
-- Description:	
-- 
-- Date			Modified By			Changes
-- 01/23/2007   Aron E. Tekulsky    Initial Coding.
-- 05/16/2019   Aron E. Tekulsky    Update to Version 140.
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
	SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED



	DECLARE @dbid				INT
	DECLARE @descr_hold			VARCHAR(1000)
	DECLARE @hold				INT
	DECLARE @name				SYSNAME
	DECLARE @status				INT
	DECLARE @status2			INT
	DECLARE @stat_descr			VARCHAR(1000)
	DECLARE @stat_descr_hold	VARCHAR(1000)

	CREATE TABLE #dbs (
		name					SYSNAME NOT NULL
		,dbid					SMALLINT NOT NULL
		,STATUS					INT NOT NULL
		,status2				INT NOT NULL
		,stat_descr				VARCHAR(1000) NULL
		)

	INSERT INTO #dbs
		SELECT name
				,dbid
				,STATUS
				,status2
				,''
			FROM master.dbo.sysdatabases;

--where name = 'master'

	UPDATE #dbs
		SET stat_descr = b.dbstatus2_description
			FROM #dbs a
				JOIN dba_db16..dbstatus2_codes b ON (a.status2 = b.dbstatus2_codes);

-- set up cursor
	DECLARE db_cur CURSOR FOR
		SELECT name
				,dbid
				,STATUS
				,status2
				,stat_descr
			FROM #dbs
		WHERE stat_descr = '';

--and name = 'msdb' -- temp for test
	OPEN db_cur

	FETCH NEXT FROM db_cur
			INTO 
				@name, @dbid, @status, @status2, @stat_descr;

	PRINT @@fetch_status

	WHILE @@fetch_status = 0
	--	print @descr_hold +@stat_descr_hold +@hold
		BEGIN
	--	select @hold = @status - 1073741824
			SELECT @hold = @status2;

			IF @hold >= 536870912
				BEGIN
		-- get the description
					SELECT @stat_descr_hold = dbstatus2_description
						FROM dbstatus2_codes
					WHERE dbstatus2_codes = 536870912;

		-- save the description
					SELECT @descr_hold = isnull(@descr_hold, '') + ', ' + @stat_descr_hold;

		-- reset the status value
					SELECT @hold = @hold - 536870912;
				END

	-- check the next number
			IF @hold >= 268435456
				BEGIN
					SELECT @stat_descr_hold = dbstatus2_description
						FROM dbstatus2_codes
					WHERE dbstatus2_codes = 268435456;

					SELECT @descr_hold = isnull(@descr_hold, '') + ', ' + @stat_descr_hold;

					SELECT @hold = @hold - 268435456;
				END

	-- check the next number
			IF @hold >= 67108864
				BEGIN
					SELECT @stat_descr_hold = dbstatus2_description
						FROM dbstatus2_codes
					WHERE dbstatus2_codes = 67108864;

					SELECT @descr_hold = isnull(@descr_hold, '') + ', ' + @stat_descr_hold;

					SELECT @hold = @hold - 67108864;
				END

	-- check the next number
			IF @hold >= 33554432
				BEGIN
					SELECT @stat_descr_hold = dbstatus2_description
						FROM dbstatus2_codes
					WHERE dbstatus2_codes = 33554432;

					SELECT @descr_hold = isnull(@descr_hold, '') + ', ' + @stat_descr_hold;

					SELECT @hold = @hold - 33554432;
				END

	-- check the next number
			IF @hold >= 8388608
				BEGIN
					SELECT @stat_descr_hold = dbstatus2_description
						FROM dbstatus2_codes
					WHERE dbstatus2_codes = 8388608;

					SELECT @descr_hold = isnull(@descr_hold, '') + ', ' + @stat_descr_hold;

					SELECT @hold = @hold - 8388608;
				END

	-- check the next number
			IF @hold >= 1048576
				BEGIN
					SELECT @stat_descr_hold = dbstatus2_description
						FROM dbstatus2_codes
					WHERE dbstatus2_codes = 1048576;

					SELECT @descr_hold = isnull(@descr_hold, '') + ', ' + @stat_descr_hold;

					SELECT @hold = @hold - 1048576;
				END

	-- check the next number
			IF @hold >= 131072
				BEGIN
					SELECT @stat_descr_hold = dbstatus2_description
						FROM dbstatus2_codes
					WHERE dbstatus2_codes = 131072;

					SELECT @descr_hold = isnull(@descr_hold, '') + ', ' + @stat_descr_hold;

					SELECT @hold = @hold - 131072;
				END

	-- check the next number
			IF @hold >= 65536
				BEGIN
					SELECT @stat_descr_hold = dbstatus2_description
						FROM dbstatus2_codes
					WHERE dbstatus2_codes = 65536;

					SELECT @descr_hold = isnull(@descr_hold, '') + ', ' + @stat_descr_hold;
			
					SELECT @hold = @hold - 65536;
				END

	-- check the next number
			IF @hold >= 16384
				BEGIN
					SELECT @stat_descr_hold = dbstatus2_description
						FROM dbstatus2_codes
					WHERE dbstatus2_codes = 16384;

					SELECT @descr_hold = isnull(@descr_hold, '') + ', ' + ', ' + @stat_descr_hold;

					SELECT @hold = @hold - 16384;
				END

			PRINT @hold;
			PRINT @descr_hold;
			PRINT @stat_descr_hold;

	-- eliminate leading comma
			IF substring(@descr_hold, 1, 1) = ','
				SELECT @descr_hold = substring(@descr_hold, 2, len(@descr_hold) - 1);

	-- do the update	
			UPDATE #dbs
				SET stat_descr = @descr_hold
					FROM #dbs a
				WHERE a.dbid = @dbid;

			FETCH NEXT FROM db_cur
				INTO 
					@name, @dbid, @status, @status2, @stat_descr;

	--initialize
			SELECT @descr_hold = ''
					,@stat_descr_hold = ''
					,@hold = 0;
		END

	SELECT *
		FROM #dbs;

	DROP TABLE #dbs;

	CLOSE db_cur;

	DEALLOCATE db_cur;


END
GO
