SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- ======================================================================================
-- dba19_sys_GetDBSizesDetailNew
--
--
-- Calls:		None
--
-- Description:	Get the db sizes detail new version.
-- 
-- Date			Modified By			Changes
-- 01/20/2016   Aron E. Tekulsky    Initial Coding.
-- 10/07/2017   Aron E. Tekulsky    Update to Version 140.
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

	SELECT [Database Name] = DB_NAME(database_id),
			[Type] = CASE
					 WHEN Type_Desc = 'ROWS' THEN 'Data File(s)'
                     WHEN Type_Desc = 'LOG'  THEN 'Log File(s)'
                     ELSE Type_Desc END,
			[Size in MB] = CAST( ((SUM(Size)* 8) / 1024.0) AS DECIMAL(18,2) )
		FROM   sys.master_files
--— Uncomment if you need to query for a particular database
--— WHERE      database_id = DB_ID(‘Database Name’)
--WHERE Type_Desc <> 'ROWS' AND Type_Desc <> 'LOG'
	GROUP BY      GROUPING SETS
              (
                     (DB_NAME(database_id), Type_Desc)--,
                     --(DB_NAME(database_id))
              )
	ORDER BY      DB_NAME(database_id) DESC, Type_Desc DESC;

END
GO
