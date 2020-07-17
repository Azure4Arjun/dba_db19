SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- ======================================================================================
-- dba16_sys_GetDBSsizesDetail
--
--
-- Calls:		None
--
-- Description:	Get db sizes detail.
-- 
-- Date			Modified By			Changes
-- 05/08/2013   Aron E. Tekulsky    Initial Coding.
-- 10/07/2017   Aron E. Tekulsky    Update to Version 140.
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

	SELECT DB_NAME(dbid) AS dbname, ROUND(CONVERT(float, size) *
		 (SELECT low
			  FROM master.dbo.spt_values
		  WHERE (type = 'E') AND (number = 1)) / 1048576, 1) AS sizemb, dbid, CASE fileid WHEN 1 THEN 'D' ELSE 'L' END AS Expr1, fileid
		FROM sys.sysaltfiles
END
GO
