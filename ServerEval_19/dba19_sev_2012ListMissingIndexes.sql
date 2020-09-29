SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- ======================================================================================
-- dba19_sev_2012ListMissingIndexes
--
--
-- Calls:		None
--
-- Description:	2012 - List missing indexes.
--
-- From Edward Roepe - Perimeter DBA, LLC.  - www.perimeterdba.com
-- 
-- Date			Modified By			Changes
-- 09/08/2018   Aron E. Tekulsky    Initial Coding.
-- 06/10/2019   Aron E. Tekulsky    Update to Version 140.
-- 08/14/2020   Aron E. Tekulsky    Update to Version 150.
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

-- 2012 - List missing indexes

-- 01/22/10 - Ed Roepe

	SELECT SERVERPROPERTY('ServerName') AS 'InstanceName', 
		   migs.avg_total_user_cost * (migs.avg_user_impact / 100.0) * (migs.user_seeks + migs.user_scans) AS 'ImprovementMeasure', 
		   mid.statement AS 'TableName', 
		   'CREATE INDEX [missing_index_'+CONVERT(VARCHAR, mig.index_group_handle)+'_'+CONVERT(VARCHAR, mid.index_handle)+'_'+LEFT(PARSENAME(mid.statement, 1), 32)+']'+' ON '+mid.statement+' ('+ISNULL(mid.equality_columns, '')+
		   CASE
			   WHEN mid.equality_columns IS NOT NULL
					AND mid.inequality_columns IS NOT NULL
														THEN ','
			   ELSE ''
		   END
		   +ISNULL(mid.inequality_columns, '')+')'+ISNULL(' INCLUDE ('+mid.included_columns+')', '') AS CreateIndexStatement, 
		   migs.*, 
		   mid.database_id, 
		   mid.[object_id]
		FROM sys.dm_db_missing_index_groups mig
			 INNER JOIN sys.dm_db_missing_index_group_stats migs ON migs.group_handle = mig.index_group_handle
			 INNER JOIN sys.dm_db_missing_index_details mid ON mig.index_handle = mid.index_handle
	WHERE migs.avg_total_user_cost * (migs.avg_user_impact / 100.0) * (migs.user_seeks + migs.user_scans) > 10
	ORDER BY migs.avg_total_user_cost * migs.avg_user_impact * (migs.user_seeks + migs.user_scans) DESC;

END
GO
