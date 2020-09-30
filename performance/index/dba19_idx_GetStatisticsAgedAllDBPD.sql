SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- ======================================================================================
-- dba19_idx_GetStatisticsAgedAllDBPD
--
--
-- Calls:		None
--
-- Description:	Script - Find Details for Statistics of Whole Database
--						(c) Pinal Dave
--				Download Script from - https://blog.sqlauthority.com/contact-me/
--				sign-up/
-- 
-- Date			Modified By			Changes
-- 02/24/2018   Aron E. Tekulsky    Initial Coding.
-- 02/20/2018   Aron E. Tekulsky    Update to Version 140.
-- 08/11/2020   Aron E. Tekulsky    Update to Version 150.
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

	DECLARE @Cmd			nvarchar(4000)
	DECLARE @DBName			nvarchar(128)

	DECLARE @Stattab TABLE (
		DBName				nvarchar(128) NULL,
		TableName			nvarchar(128) NULL,
		ColumnName			nvarchar(128) NULL,
		StatName			nvarchar(128) NULL,
		LastUpdated			datetime NULL,
		DaysOld				int NULL,
		ModificationCounter int NULL,
		AutoCreate			bit NULL,
		UserCreated			bit NULL,
		NOReComput			bit NULL,
		ObjectId			int NULL,
		StatsId				int NULL,
		StatsColumnId		int NULL,
		ColumnId			int NULL
	)

	DECLARE db_cur CURSOR FOR
		SELECT d.name
			FROM sys.databases d
				JOIN sys.syslogins l ON (d.owner_sid = l.sid)
		WHERE database_id > 4 AND
			state = 0 AND d.name NOT IN ('dba_db08','SSISDB','ReportServer','ReportServerTempDB');

	OPEN db_cur;

	FETCH NEXT FROM db_cur INTO
		@DBName;

	SET @Cmd = '';

	WHILE (@@FETCH_STATUS <> -1)
		BEGIN
			SET @Cmd = 'USE [' + @DBName + '] ' + CHAR(13) ;

			SET @Cmd = @Cmd +
				'SELECT DISTINCT ' + '''' + @DBName + '''' + ',OBJECT_NAME(s.
						[object_id]) AS TableName,
						c.name AS ColumnName,
						s.name AS StatName,
						STATS_DATE(s.[object_id], s.stats_id) AS LastUpdated,
						DATEDIFF(d,STATS_DATE(s.[object_id], s.stats_id),getdate())
						DaysOld,
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
				WHERE OBJECTPROPERTY(s.OBJECT_ID,' + '''' + 'IsUserTable' + '''' + ') = 1
					AND (s.auto_created = 1 OR s.user_created = 1)
					AND DATEDIFF(d,STATS_DATE(s.[object_id], s.stats_id),getdate()) > 0
				ORDER BY DaysOld DESC;';

			PRINT @Cmd;

			INSERT INTO @Stattab (
				DBName,
				TableName,
				ColumnName,
				StatName,
				LastUpdated,
				DaysOld,
				ModificationCounter,
				AutoCreate,
				UserCreated,
				NOReComput,
				ObjectId,
				StatsId,
				StatsColumnId,
				ColumnId)
			EXEC(@Cmd);

			FETCH NEXT FROM db_cur INTO
				@DBName;
		END

	CLOSE db_cur;
	DEALLOCATE db_cur;

	SELECT DBName,
			TableName,
			ColumnName,
			DaysOld,
			LastUpdated,
			StatName,
			ModificationCounter,
			AutoCreate,
			UserCreated,
			NOReComput,
			ObjectId,
			StatsId,
			StatsColumnId,
			ColumnId
		FROM @Stattab
	ORDER BY DBName ASC, DaysOld DESC;

END
GO
