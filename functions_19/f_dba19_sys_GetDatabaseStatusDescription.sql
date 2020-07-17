SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- ======================================================================================
-- f_dba19_sys_GetDatabaseStatusDescription
--
--  Scalar_Function template
--
-- Arguments:	@intstatus
--				None
--
-- CallS:		None
--
-- Called BY:	None
--
-- Description:	Get the database status description.
--
-- Date			Modified By			Changes
-- 01/23/2007   Aron E. Tekulsky    Initial Coding.
-- 04/18/2012	Aron E. Tekulsky	Update to v100.
-- 12/25/2017   Aron E. Tekulsky    Update to Version 140.
-- 05/19/2020   Aron E. Tekulsky    Update to Version 150.
-- ======================================================================================
--	Copyright©2001 - 2025 Aron Tekulsky.  World wide rights reserved.
--	Use of this code is free of charge but does not in any way imply transfer of 
--	Copyright ownership to the user.
-- ======================================================================================
--
CREATE FUNCTION f_dba19_sys_GetDatabaseStatusDescription 
(
	-- Add the parameters for the function here
	@intstatus int
)
RETURNS varchar(1000)

AS
BEGIN
	-- Declare the return variable here
	DECLARE @stringstatus varchar(1000)

	-- Add the T-SQL statements to compute the return value here
	DECLARE @name				sysname ,
			@dbid				int,
			@status				int,
			@status2			int,
			@stat_descr			varchar(100),
			@hold				int,
			@descr_hold			varchar(100),
			@stat_descr_hold	varchar(100)

--create table #dbs 
--(name	sysname not null,
--dbid	smallint not null,
--status	int not null,
--status2	int not null,
--stat_descr	varchar(100) null)
--
--insert into #dbs
--SELECT name, dbid, status, status2, ''
--FROM master.dbo.sysdatabases
----WHERE name = 'master'

--update #dbs
--	set stat_descr = b.dbstatus_description
--FROM #dbs a,
--dba_db..dbstatus_codes b
--WHERE a.status = b.dbstatus_codes

---- set up cursor
--
--declare db_cur cursor for
--	SELECT name, dbid, status, status2, stat_descr
--	FROM #dbs
--	WHERE stat_descr = ''
--   --and name = 'msdb' -- temp for test
--
--open db_cur
--
--fetch next FROM db_cur into @name,@dbid, @status, @status2, @stat_descr
--
--print @@fetch_status
--
--while @@fetch_status = 0

----	print @descr_hold +@stat_descr_hold +@hold
--
--
--BEGIN
--	SELECT @hold = @status - 1073741824
	SELECT @hold = @intstatus;

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

-- check the next number
	IF @hold >= 4194304 
		BEGIN
			SELECT @stat_descr_hold = dbstatus_description
				FROM dbstatus_codes
			WHERE dbstatus_codes = 4194304;

			SELECT @descr_hold = isnull(@descr_hold,'') + ', '+ @stat_descr_hold;

			SELECT @hold = @hold - 4194304;
		END

-- check the next number
	IF @hold >= 32768 
		BEGIN
			SELECT @stat_descr_hold = dbstatus_description
				FROM dbstatus_codes
			WHERE dbstatus_codes = 32768;

			 SELECT @descr_hold = isnull(@descr_hold,'') + ', '+ @stat_descr_hold;

			 SELECT @hold = @hold - 32768;
		END

-- check the next number
	IF @hold >= 4096 
		BEGIN
			SELECT @stat_descr_hold = dbstatus_description
				FROM dbstatus_codes
			WHERE dbstatus_codes = 4096;

			SELECT @descr_hold = isnull(@descr_hold,'') + ', '+ @stat_descr_hold;

			SELECT @hold = @hold - 4096;
		END


-- check the next number
	IF @hold >= 2048 
		BEGIN
			 SELECT @stat_descr_hold = dbstatus_description
				FROM dbstatus_codes
			WHERE dbstatus_codes = 2048;

			SELECT @descr_hold = isnull(@descr_hold,'') + ', '+ @stat_descr_hold;

			SELECT @hold = @hold - 2048;
		END

-- check the next number
	IF @hold >= 1024 
		BEGIN
		 SELECT @stat_descr_hold = dbstatus_description
			FROM dbstatus_codes
		WHERE dbstatus_codes = 1024;

		 SELECT @descr_hold = isnull(@descr_hold,'') + ', '+ @stat_descr_hold;

	     SELECT @hold = @hold - 1024;
		END

-- check the next number
	IF @hold >= 512 
		BEGIN
			SELECT @stat_descr_hold = dbstatus_description
				FROM dbstatus_codes
			WHERE dbstatus_codes = 512;

			SELECT @descr_hold = isnull(@descr_hold,'') + ', '+ @stat_descr_hold;

			SELECT @hold = @hold - 512;
		END
	

-- check the next number
	IF @hold >= 256 
		BEGIN
			SELECT @stat_descr_hold = dbstatus_description
				FROM dbstatus_codes
			WHERE dbstatus_codes = 256;

			SELECT @descr_hold = isnull(@descr_hold,'') + ', '+ @stat_descr_hold;

			SELECT @hold = @hold - 256;
		END


-- check the next number
	IF @hold >= 128 
		BEGIN
			SELECT @stat_descr_hold = dbstatus_description
				FROM dbstatus_codes
			WHERE dbstatus_codes = 128;

			SELECT @descr_hold = isnull(@descr_hold,'') + ', '+ ', '+ @stat_descr_hold;

			SELECT @hold = @hold - 128;
		END


-- check the next number
	IF @hold >= 64 
		BEGIN
			SELECT @stat_descr_hold = dbstatus_description
				FROM dbstatus_codes
			WHERE dbstatus_codes = 64;

			SELECT @descr_hold = isnull(@descr_hold,'') + ', '+ @stat_descr_hold;

			SELECT @hold = @hold - 64;
		END


-- check the next number
	IF @hold >= 32 
		BEGIN
			SELECT @stat_descr_hold = dbstatus_description
				FROM dbstatus_codes
			WHERE dbstatus_codes = 32;

			SELECT @descr_hold = isnull(@descr_hold,'') + ', '+ @stat_descr_hold;

			SELECT @hold = @hold - 32;
		END

-- check the next number
	IF @hold >= 16 
		BEGIN
			SELECT @stat_descr_hold = dbstatus_description
				FROM dbstatus_codes
			WHERE dbstatus_codes = 16;

			SELECT @descr_hold = isnull(@descr_hold,'') + ', '+ @stat_descr_hold;

			SELECT @hold = @hold - 16;
		END

--print @hold
--print @descr_hold
--print @stat_descr_hold

-- check the next number
	IF @hold >= 8 
		BEGIN
			SELECT @stat_descr_hold = dbstatus_description
				FROM dbstatus_codes
			WHERE dbstatus_codes = 8;

			SELECT @descr_hold = isnull(@descr_hold,'') + ', '+ @stat_descr_hold;

			SELECT @hold = @hold - 8;
		END


-- check the next number
	IF @hold >= 4 
		BEGIN
			SELECT @stat_descr_hold = dbstatus_description
				FROM dbstatus_codes
			WHERE dbstatus_codes = 4;

			SELECT @descr_hold = isnull(@descr_hold,'') + ', '+ @stat_descr_hold;

			SELECT @hold = @hold - 4;
		END


-- check the next number
	IF @hold >= 1 
		BEGIN
			SELECT @stat_descr_hold = dbstatus_description
				FROM dbstatus_codes
			WHERE dbstatus_codes = 1;

			SELECT @descr_hold = isnull(@descr_hold,'') + ', '+@stat_descr_hold;

			SELECT @hold = @hold - 1;
		END

-- eliminate leading comma
    IF substring(@descr_hold,1,1) = ','
        SELECT @stringstatus = substring(@descr_hold,2,len(@descr_hold)-1);
    ELSE    
        SELECT @stringstatus = @descr_hold;

---- do the update	
--	update #dbs
--		set stat_descr = @descr_hold
--	FROM #dbs a
--	WHERE a.dbid = @dbid
--
--	fetch next FROM db_cur into @name,@dbid, @status, @status2, @stat_descr
----initialize
--	SELECT @descr_hold = '', @stat_descr_hold = '', @hold = 0
--END


--SELECT * FROM #dbs
--
--drop table #dbs
--
--close db_cur
--
--deallocate db_cur
	-- Return the result of the function
	RETURN @stringstatus

END
GO
GRANT EXECUTE ON [dbo].[f_dba19_sys_GetDatabaseStatusDescription] TO [db_proc_exec]
GO
