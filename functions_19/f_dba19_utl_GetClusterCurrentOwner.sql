----USE [dba_db16]
----GO

/****** Object:  UserDefinedFunction [dbo].[f_dba19_utl_GetClusterCurrentOwner]    Script Date: 7/15/2020 3:49:22 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

-- ======================================================================================
-- f_dba19_utl_GetClusterCurrentOwner
--
-- Arguments:	None
--				None
--
-- Function DT:	varchar(128)
--
-- Results:		@OwnerNode
--
-- Description:	Get the node that is the current owner.
-- 
-- NOTE: sys.dm_serverServices has bit to tell if aq cluster exists.
-- Date			Modified By			Changes
-- 07/15/2020   Aron E. Tekulsky    Initial Coding.
-- 07/15/2020   Aron E. Tekulsky    Update to Version 150.
-- ======================================================================================
--	Copyright©2001 - 2025 Aron Tekulsky.  World wide rights reserved.
--	Use of this code is free of charge but does not in any way imply transfer of 
--	Copyright ownership to the user.
-- ======================================================================================
--
CREATE FUNCTION [dbo].[f_dba19_utl_GetClusterCurrentOwner] 
(
	-- Add the parameters for the function here
	--None int
)
RETURNS varchar(128)
AS
BEGIN
	-- Declare the return variable here
	DECLARE @OwnerNode varchar(128)

	-- Add the T-SQL statements to compute the return value here
	SELECT @OwnerNode = [NodeName]
		FROM [master].[sys].[dm_os_cluster_nodes]
	WHERE [is_current_owner] = 1;

	-- Return the result of the function
	RETURN @OwnerNode

END
GO


