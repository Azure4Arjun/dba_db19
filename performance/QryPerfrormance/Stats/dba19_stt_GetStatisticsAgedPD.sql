SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- ======================================================================================
-- dba19_stt_GetStatisticsAgedPD
--
--
-- Calls:		None
--
-- Description:	Script - Find Details for Statistics of Whole Database
--				(c) Pinal Dave
--				Download Script from - https://blog.sqlauthority.com/contact-me/
--				sign-up/
-- 
-- Date			Modified By			Changes
-- 02/20/2018   Aron E. Tekulsky    Initial Coding.
-- 08/12/2020   Aron E. Tekulsky    Update to Version 150.
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

	SELECT DISTINCT OBJECT_NAME(s.[object_id]) AS TableName,
			c.name AS ColumnName,
			DATEDIFF(d,STATS_DATE(s.[object_id], s.stats_id),getdate()) DaysOld,
			STATS_DATE(s.[object_id], s.stats_id) AS LastUpdated,
			s.name AS StatName,
			dsp.modification_counter,
			s.auto_created,
			s.user_created,
			s.no_recompute,
			s.[object_id],
			s.stats_id,
			sc.stats_column_id,
			sc.column_id
		FROM sys.stats s
			JOIN sys.stats_columns sc ON (sc.[object_id] = s.[object_id]) AND
										(sc.stats_id = s.stats_id)
			JOIN sys.columns c ON (c.[object_id] = sc.[object_id]) AND
									(c.column_id = sc.column_id)
			JOIN sys.partitions par ON (par.[object_id] = s.[object_id])
			JOIN sys.objects obj ON (par.[object_id] = obj.[object_id])
			CROSS APPLY sys.dm_db_stats_properties(sc.[object_id], s.stats_id) AS dsp
	WHERE OBJECTPROPERTY(s.OBJECT_ID,'IsUserTable') = 1
			AND (s.auto_created = 1 OR s.user_created = 1)
	ORDER BY DaysOld DESC;

END
GO
