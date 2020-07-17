SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- ======================================================================================
-- dba16_sys_SysDBMaintPlanHistory2
--
--
-- Calls:		None
--
-- Description:	
-- 
-- Date			Modified By			Changes
-- 10/07/2002   Aron E. Tekulsky	Initial Coding.
-- 04/04/2012	Aron E. Tekulsky	Update to v100.
-- 01/03/2018   Aron E. Tekulsky    Update to V140.
-- ======================================================================================
--	Copyright©2001 - 2025 Aron Tekulsky.  World wide rights reserved.
--	Use of this code is free of charge but does not in any way imply transfer of 
--	Copyright ownership to the user.
-- ======================================================================================
--
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	SELECT  plan_name, database_name, activity, succeeded,start_time, end_time, duration, error_number, message
		FROM msdb..sysdbmaintplan_history
	WHERE datediff(day, start_time,getdate()) = 0
	ORDER BY start_time desc


END
GO
