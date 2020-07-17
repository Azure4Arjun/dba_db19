SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- ======================================================================================
-- f_dba19_sys_GetInstanceNameAfterSlash
--
--
-- Arguments:	@P1		nvarchar(4000)
--				None
--
-- CallS:		None
--
-- Called BY:	None
--
-- Description:	
--
-- Date			Modified By			Changes
-- 02/06/2013   Aron E. Tekulsky    Initial Coding.
-- 09/10/2018   Aron E. Tekulsky    Update to Version 140.
-- 05/19/2018   Aron E. Tekulsky    Update to Version 150.
-- ======================================================================================
--	Copyright©2001 - 2025 Aron Tekulsky.  World wide rights reserved.
--	Use of this code is free of charge but does not in any way imply transfer of 
--	Copyright ownership to the user.
-- ======================================================================================
--
CREATE FUNCTION FunctionName 
(
	-- Add the parameters for the function here
	@P1		nvarchar(4000)
)
RETURNS nvarchar(4000)
AS
BEGIN
	-- Declare the return variable here
	DECLARE @Result			nvarchar(4000)

	-- Add the T-SQL statements to compute the return value here
	DECLARE @char_location	int
	DECLARE @start_pos		int

	SET @char_location = 1
--SET @p1 = 'C:\Program Files\Microsoft SQL Server\MSSQL10_50.DBS2008R2\MSSQL\DATA\master.mdf'

	SET @start_pos = 1

-- Add the T-SQL statements to compute the return value here
	SET @char_location = CHARINDEX('\',@p1,@start_pos)

	IF @char_location > 0
		BEGIN
			SET @p1 = SUBSTRING(@p1,@char_location + 1 , LEN(@p1) - @char_location)
			SET @start_pos = 1
--print 'startpos ' + convert(varchar(5), @start_pos)
		END

	SET @Result = @p1

	-- Return the result of the function
	RETURN @Result

END
GO

