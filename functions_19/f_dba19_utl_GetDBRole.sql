USE [dba_db19]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- ======================================================================================
-- f_dba19_utl_GetDBRole
--
--  Scalar_Function template
--
-- Arguments:	@dbname	nvarchar(128)
--				None
--
-- CallS:		None
--
-- Called BY:	None
--
-- Description:	Get the role of the database on the present server.
--				return @Result 1 - Primary 2 Secondary
--
-- Date			Modified By			Changes
-- 06/17/2016   Aron E. Tekulsky    Initial Coding.
-- 12/26/2017   Aron E. Tekulsky    Update to V140.
-- 05/19/2020   Aron E. Tekulsky    Update to V150.
-- ======================================================================================
--	Copyright©2001 - 2025 Aron Tekulsky.  World wide rights reserved.
--	Use of this code is free of charge but does not in any way imply transfer of 
--	Copyright ownership to the user.
-- ======================================================================================
--
CREATE FUNCTION [dbo].[f_dba19_utl_GetDBRole] 
(
	-- Add the parameters for the function here
	@dbname nvarchar(128)
)
RETURNS tinyint
AS
BEGIN
	-- Declare the return variable here
	DECLARE @Result tinyint

	-- Add the T-SQL statements to compute the return value here
	SELECT @Result = s.[role]
	--d.name
		--s.[replica_id]
      --,s.[group_id]
      --,s.[is_local]
      --,
	  --s.[role]
      --,s.[role_desc]
      --,s.[operational_state]
      --,s.[operational_state_desc]		
      --,s.[connected_state]
      --,s.[connected_state_desc]
      --,s.[recovery_health]
      --,s.[recovery_health_desc]
      --,s.[synchronization_health]
      --,s.[synchronization_health_desc]
      --,s.[last_connect_error_number]
      --,s.[last_connect_error_description]
      --,s.[last_connect_error_timestamp]
		FROM [master].[sys].[dm_hadr_availability_replica_states] s
			JOIN sys.databases d ON (s.replica_id = d.replica_id )
	WHERE d.name = @dbname;

	-- Return the result of the function
	RETURN @Result

END

