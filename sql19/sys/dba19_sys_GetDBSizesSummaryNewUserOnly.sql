SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- ======================================================================================
-- dba19_sys_GetDBSizesSummaryNewUserOnly
--
--
-- Calls:		None
--
-- Description:	Get DB sizes summary new for user db only.
-- 
-- Date			Modified By			Changes
-- 09/12/2016   Aron E. Tekulsky    Initial Coding.
-- 10/16/2017   Aron E. Tekulsky    Update to Version 140.
-- 08/25/2020   Aron E. Tekulsky    Update to Version 150.
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
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;

	SELECT [Database Name] = DB_NAME(m.database_id),
       --[Type] = CASE WHEN Type_Desc = 'ROWS' THEN 'Data File(s)'
       --              WHEN Type_Desc = 'LOG'  THEN 'Log File(s)'
       --              ELSE Type_Desc END,
		 [Size in MB] = CAST( ((SUM(m.Size)* 8) / 1024.0) AS DECIMAL(18,2) )
		FROM   sys.master_files m
			JOIN sys.databases d ON (d.database_id = m.database_id)
			--JOIN sys.syslogins l ON (l.sid = d.owner_sid)
--— Uncomment if you need to query for a particular database
--— WHERE      database_id = DB_ID(‘Database Name’)
--WHERE Type_Desc <> 'ROWS' AND Type_Desc <> 'LOG'
	WHERE m.database_id > 4 AND
			d.state_desc = 'ONLINE'
		--AND DB_NAME(m.database_id) LIKE ('ADVENTUR%')
	GROUP BY GROUPING SETS
              (
                     --(DB_NAME(database_id), Type_Desc),
                     (DB_NAME(m.database_id))
              )
	ORDER BY     [Size in MB]  Desc,  DB_NAME(m.database_id) ASC; --, Type_Desc DESC

END
GO
