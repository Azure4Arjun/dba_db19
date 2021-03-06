SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- ======================================================================================
-- dba16_dig_DMGetOsWaitingTasks
--
--
-- Calls:		None
--
-- Description:	Get O/S waiting tasks list.
-- 
-- Date			Modified By			Changes
-- 07/27/2012   Aron E. Tekulsky    Initial Coding.
-- ======================================================================================
--	Copyrightę2001 - 2025 Aron Tekulsky.  World wide rights reserved.
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

	/****** Script for SelectTopNRows command from SSMS  ******/
	SELECT TOP 1000 [waiting_task_address],[session_id],[exec_context_id],[wait_duration_ms],[wait_type],[resource_address],[blocking_task_address]
		,[blocking_session_id],[blocking_exec_context_id],[resource_description]
		FROM [master].[sys].[dm_os_waiting_tasks]
	ORDER BY [wait_type] ASC

END
GO
