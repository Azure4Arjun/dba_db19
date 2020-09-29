SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- ======================================================================================
-- dba19_job_GetJobCategories
--
--
-- Calls:		None
--
-- Description:	Get a listing of all Job Categories in MSDB.
-- 
-- Date			Modified By			Changes
-- 04/06/2020   Aron E. Tekulsky    Initial Coding.
-- 04/06/2020   Aron E. Tekulsky    Update to Version 150.
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

    -- Insert statements for procedure here
	SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;

	SELECT CASE c.category_class
				WHEN 1 THEN 'JOB'
				WHEN 2 THEN 'ALERT'
				WHEN 3 THEN 'OPERATOR'
			END AS category_class, 
			CASE c.category_type
				WHEN 1 THEN 'LOCAL'
				WHEN 2 THEN 'MULTISERVER'
				WHEN 0 THEN 'NONE'
			END as category_type, 
			c.name
		FROM msdb.dbo.syscategories c;

END
GO
