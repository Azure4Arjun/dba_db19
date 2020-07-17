SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- ======================================================================================
-- v_dba19_sys_JobStepCounts
--
--
-- Calls:		None
--
-- Description:	
-- 
-- Date			Modified By			Changes
-- 02/14/2014   Aron E. Tekulsky    Initial Coding.
-- 02/11/2018   Aron E. Tekulsky    Update to V140.
-- 05/19/2020   Aron E. Tekulsky    Update to V150.
-- ======================================================================================
--	Copyright©2001 - 2025 Aron Tekulsky.  World wide rights reserved.
--	Use of this code is free of charge but does not in any way imply transfer of 
--	Copyright ownership to the user.
-- ======================================================================================
--
----BEGIN
----	-- SET NOCOUNT ON added to prevent extra result sets from
----	-- interfering with SELECT statements.
----	SET NOCOUNT ON;

    -- Insert statements for procedure here

	CREATE VIEW [dbo].[v_dba19_sys_JobStepCounts] AS
		SELECT j.job_id, j.name, count(s.job_id) AS step_count
			FROM msdb.dbo.sysjobs j
				JOIN msdb.dbo.sysjobsteps s ON (s.job_id = j.job_id)
		GROUP BY j.job_id, j.name;
--order by j.name asc
--GO


----GRANT REFERENCES ON [dbo].[v_dba19_sys_JobStepCounts] TO [db_proc_exec] AS [dbo]
----GO

----GRANT SELECT ON [dbo].[v_dba19_sys_JobStepCounts] TO [db_proc_exec] AS [dbo]
----GO

--END
GO
