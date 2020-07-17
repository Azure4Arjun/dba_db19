SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- ======================================================================================
-- f_dba19_sys_FileExists
--
-- Arguments:	@filename
--				None
--
-- CallS:		None
--
-- Called BY:	None
--
-- Description:	Check to see if a file exists.
--				0 - no
--				1 - yes.
--
-- Date			Modified By			Changes
-- 02/17/2012   Aron E. Tekulsky    Initial Coding.
-- 04/18/2012	Aron E. Tekulsky	Update to v100.
-- 02/25/2012   Aron E. Tekulsky    Update to Version 140.
-- 05/19/2020   Aron E. Tekulsky    Update to Version 150.
-- ======================================================================================
--	Copyright©2001 - 2025 Aron Tekulsky.  World wide rights reserved.
--	Use of this code is free of charge but does not in any way imply transfer of 
--	Copyright ownership to the user.
-- ======================================================================================
--
CREATE FUNCTION f_dba19_sys_FileExists 
(
	-- Add the parameters for the function here
	@filename nvarchar(2000)
)
RETURNS int
AS
BEGIN
	-- Declare the return variable here
	DECLARE @Result int

	-- Add the T-SQL statements to compute the return value here
	EXEC master.DBO.xp_fileexist @Filename, @Result OUTPUT


	-- Return the result of the function
	RETURN @Result

END
GO

GRANT EXECUTE ON [dbo].[f_dba19_sys_FileExists] TO [db_proc_exec]
GO
GRANT REFERENCES ON [dbo].[f_dba19_sys_FileExists] TO [db_proc_exec]
GO
GRANT VIEW DEFINITION ON [dbo].[f_dba19_sys_FileExists] TO [db_proc_exec]