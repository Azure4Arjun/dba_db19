SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- ======================================================================================
-- p_dba19_dig_DMSetBlocking
--
-- Arguments:	None
--				None
--
-- CallS:		None
--
-- Called BY:	None
--
-- Description:	Insert into the dm_blocking table to show history of blocks.
-- 
-- Date			Modified By			Changes
-- 10/07/2013   Aron E. Tekulsky    Initial Coding.
-- 02/13/2018   Aron E. Tekulsky    Update to Version 140.
-- 08/12/2020   Aron E. Tekulsky    Update to Version 150.
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
CREATE PROCEDURE p_dba19_dig_DMSetBlocking 
	-- Add the parameters for the stored procedure here
----	None int = 0, 
----	None int = 0
----AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;

	INSERT INTO [dbo].[dba_dm_blocking]
	       ([session_id]
           ,[blocking_session_id]
           ,[insert_date]
           ,[status]
           ,[sql_handle]
           ,[plan_handle]
           ,[database_id]
           ,[user_id]
           ,[wait_type]
           ,[wait_time]
           ,[last_wait_type]
           ,[wait_resource]
           ,[start_time]
           ,[lock_timeout]
           ,[deadlock_priority]
           ,[transaction_isolation_level]
           ,[nest_level]
           ,[command])
	SELECT	session_id,
			blocking_session_id,
			GETDATE(),
			status,
			sql_handle,
			plan_handle,
			database_id,
			user_id,
			wait_type,
			wait_time,
			last_wait_type,
			wait_resource,
			start_time,
			lock_timeout,
			deadlock_priority,
			transaction_isolation_level,
			nest_level,
			command
			--transaction_id , 
			--total_elapsed_time,
		FROM sys.dm_exec_requests 
	WHERE status = N'suspended'
	ORDER BY total_elapsed_time DESC;

	IF @@ERROR <> 0 GOTO ErrorHandler

	RETURN 1

	ErrorHandler:
	RETURN -1 
END
GO
----GRANT EXECUTE ON p_dba16_met_DMSetBlocking TO [db_proc_exec] AS [dbo]
----GO
