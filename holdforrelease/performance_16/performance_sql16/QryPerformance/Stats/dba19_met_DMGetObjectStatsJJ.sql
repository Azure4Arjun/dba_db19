SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- ======================================================================================
-- dba19_met_DMGetObjectStatsJJ
--
--
-- Calls:		None
--
-- Description:	
-- 
--				Jean Joseph
--
-- Date			Modified By			Changes
-- 10/07/2019   Aron E. Tekulsky    Initial Coding.
-- 10/07/2019   Aron E. Tekulsky    Update to Version 150.
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

	DECLARE @Cmd		nvarchar(4000)
	DECLARE @ObjName	nvarchar(128)
	DECLARE @SchemaName	nvarchar(128)

	-- initialize
	SET @ObjName	= 'database_expiration';
	SET @SchemaName = 'dbo';

	SET @Cmd = '
		SELECT OBJECT_NAME(sp.object_id) AS "Table",
				sp.stats_id AS "Statistics",
				s.name AS "Statistic", 
				sp.last_updated AS "Last Updated",
				sp.rows,
				sp.rows_sampled,
				sp.unfiltered_rows,
				sp.modification_counter AS "Modifications"
			FROM sys.stats AS s
				OUTER APPLY sys.dm_db_stats_properties(s.object_id, s.stats_id) AS sp 
		WHERE s.object_id = OBJECT_ID(N' + '''' + '[' + @SchemaName + '].[' + @ObjName + ']' + '''' + ');';

	PRINT @Cmd;

	EXEC sp_executesql @Cmd;

END
GO
