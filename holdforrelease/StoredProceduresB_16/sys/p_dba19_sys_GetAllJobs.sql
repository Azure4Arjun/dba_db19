SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- ======================================================================================
-- p_dba19_sys_GetAllJobs
--
-- Arguments:	None
--				None
--
-- CallS:		None
--
-- Called BY:	None
--
-- Description:	Get all jobs.
-- 
-- Date			Modified By			Changes
-- 07/01/2009   Aron E. Tekulsky    Initial Coding.
-- 04/19/2012	Aron E. Tekulsky	Update to v100.
-- 03/19/2018   Aron E. Tekulsky    Update to Version 140.
-- 05/26/2020   Aron E. Tekulsky    Update to Version 150.
-- ======================================================================================
--	Copyright©2001 - 2025 Aron Tekulsky.  World wide rights reserved.
--	Use of this code is free of charge but does not in any way imply transfer of 
--	Copyright ownership to the user.
-- ======================================================================================
--
CREATE PROCEDURE p_dba19_sys_GetAllJobs 
	-- Add the parameters for the stored procedure here
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;

	SELECT j.job_id, j.name, j.enabled, j.description, j.date_created
		FROM msdb.dbo.sysjobs j
	WHERE j.enabled = 1
	ORDER BY j.name ASC;

	IF @@ERROR <> 0 GOTO ErrorHandler

	RETURN 1

	ErrorHandler:
	RETURN -1 
END
GO
GRANT EXECUTE ON p_dba19_sys_GetAllJobs TO [db_proc_exec] AS [dbo]
GO
