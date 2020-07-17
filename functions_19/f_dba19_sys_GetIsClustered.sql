SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- ======================================================================================
-- f_dba19_sys_GetIsClustered
--
-- Arguments:	None
--				None
--
-- Function DT:	char(1)
--
-- Results:		@Result
--
-- Description:	Return Y or N for the node being clustered.
-- 
-- Requires VIEW SERVER STATE permission on the server.
--
-- Date			Modified By			Changes
-- 07/16/2020   Aron E. Tekulsky    Initial Coding.
-- 07/16/2020   Aron E. Tekulsky    Update to Version 150.
-- ======================================================================================
--	Copyright©2001 - 2025 Aron Tekulsky.  World wide rights reserved.
--	Use of this code is free of charge but does not in any way imply transfer of 
--	Copyright ownership to the user.
-- ======================================================================================
--
CREATE FUNCTION f_dba19_sys_GetIsClustered 
(
	-- Add the parameters for the function here
	----None int
)
RETURNS char(1)
AS
BEGIN
	-- Declare the return variable here
	DECLARE @Result char(1)

	-- Add the T-SQL statements to compute the return value here
	SELECT @Result = s.is_clustered  
		FROM sys.dm_server_Services s
	WHERE s.servicename LIKE ('SQL Server (%');


	-- Return the result of the function
	RETURN @Result

END
GO

