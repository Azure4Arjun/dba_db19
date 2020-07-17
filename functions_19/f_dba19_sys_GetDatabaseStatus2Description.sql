SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- ======================================================================================
-- f_dba19_sys_GetDatabaseStatus2Description
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
-- Description:	Get the database status2 description.
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
CREATE FUNCTION f_dba19_sys_GetDatabaseStatus2Description 
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
	DECLARE @name				sysname,
--			@dbid				int,
--			@status				int,
--			@status2			int,
--			@stat_descr			varchar(100),
			@hold				int,
			@descr_hold			varchar(100),
			@stat_descr_hold	varchar(100)

	SELECT @hold = @intstatus;

	IF @hold >= 536870912
		BEGIN
-- get the description
			SELECT @stat_descr_hold = dbstatus2_description
				FROM dbstatus2_codes
			WHERE dbstatus2_codes = 536870912;

-- save the description
			SELECT @descr_hold = isnull(@descr_hold,'') + ', '+ @stat_descr_hold;
-- reset the status value
			SELECT @hold = @hold - 536870912;
    
		END

-- check the next number
	IF @hold >= 268435456 
		BEGIN
			SELECT @stat_descr_hold = dbstatus2_description
				FROM dbstatus2_codes
			WHERE dbstatus2_codes = 268435456;

			SELECT @descr_hold = isnull(@descr_hold,'') + ', '+ @stat_descr_hold;

			SELECT @hold = @hold - 268435456;
		END

-- check the next number
	IF @hold >= 67108864 
		BEGIN
			SELECT @stat_descr_hold = dbstatus2_description
				FROM dbstatus2_codes
			WHERE dbstatus2_codes = 67108864;

			SELECT @descr_hold = isnull(@descr_hold,'') + ', '+ @stat_descr_hold;
			SELECT @hold = @hold - 67108864;
		END

-- check the next number
	IF @hold >= 33554432 
		BEGIN
			SELECT @stat_descr_hold = dbstatus2_description
				FROM dbstatus2_codes
			WHERE dbstatus2_codes = 33554432;

		 SELECT @descr_hold = isnull(@descr_hold,'') + ', '+ @stat_descr_hold;
	     SELECT @hold = @hold - 33554432;
		END


-- check the next number
	IF @hold >= 8388608 
		BEGIN
			SELECT @stat_descr_hold = dbstatus2_description
				FROM dbstatus2_codes
			WHERE dbstatus2_codes = 8388608;

		 SELECT @descr_hold = isnull(@descr_hold,'') + ', '+ @stat_descr_hold;
	     SELECT @hold = @hold - 8388608;
		END

-- check the next number
	IF @hold >= 1048576 
		BEGIN
			SELECT @stat_descr_hold = dbstatus2_description
				FROM dbstatus2_codes
			WHERE dbstatus2_codes = 1048576;

			SELECT @descr_hold = isnull(@descr_hold,'') + ', '+ @stat_descr_hold;
			SELECT @hold = @hold - 1048576;
		END

-- check the next number
	IF @hold >= 131072 
		BEGIN
			SELECT @stat_descr_hold = dbstatus2_description
				FROM dbstatus2_codes
			WHERE dbstatus2_codes = 131072;

		 SELECT @descr_hold = isnull(@descr_hold,'') + ', '+ @stat_descr_hold;
	     SELECT @hold = @hold - 131072;
		END
	

-- check the next number
	IF @hold >= 65536 
		BEGIN
			SELECT @stat_descr_hold = dbstatus2_description
				FROM dbstatus2_codes
			WHERE dbstatus2_codes = 65536;

		 SELECT @descr_hold = isnull(@descr_hold,'') + ', '+ @stat_descr_hold;
	     SELECT @hold = @hold - 65536;
		END


-- check the next number
	IF @hold >= 16384 
		BEGIN
			SELECT @stat_descr_hold = dbstatus2_description
				FROM dbstatus2_codes
			WHERE dbstatus2_codes = 16384;

		 SELECT @descr_hold = isnull(@descr_hold,'') + ', '+ ', '+ @stat_descr_hold;
	     SELECT @hold = @hold - 16384;
		END

-- eliminate leading comma
    IF substring(@descr_hold,1,1) = ','
        SELECT @stringstatus = substring(@descr_hold,2,len(@descr_hold)-1);
    ELSE    
        SELECT @stringstatus = @descr_hold;
	-- Return the result of the function
	RETURN @stringstatus

END
GO

GRANT EXECUTE ON [dbo].[f_dba19_sys_GetDatabaseStatus2Description] TO [db_proc_exec]
GO