SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- ======================================================================================
-- dba19_tbl_GetLastTimeTableUpdated
--
--
-- Calls:		None
--
-- Description:	Get a list of the last time a table was updated.
-- 
-- https://stackoverflow.com/questions/17489469/find-the-last-time-table-was-updated
--
-- Date			Modified By			Changes
-- 12/20/2019   Aron E. Tekulsky    Initial Coding.
-- 12/20/2019   Aron E. Tekulsky    Update to Version 150.
-- 02/07/2020	Aron E. Tekulsky	use DB_NAME() to get a currnt db name instead 
--									of hard coding value.
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
	DECLARE @DatabaseName	nvarchar(128)
	DECLARE @ObjectName		nvarchar(128)
	DECLARE @Schema			nvarchar(128)

	DECLARE @Results AS TABLE (
		ObjectName			nvarchar(128),
		LastUserUpdate		datetime,
		DatabaseId			smallint,
		ObjectIid			int,
		IndexId				int,
		UserSeeks			bigint,
		UuserScans			bigint,
		UserLookups			bigint,
		UserUpdates			bigint,
		LastUserSeek		datetime,
		LastUserScan		datetime,
		LastUserLookup		datetime,
		SystemSeeks			bigint,
		SystemScans			bigint,
		SystemLookups		bigint,
		SystemUpdates		bigint,
		LastSystemSeek		datetime,
		LastSystemScan		datetime,
		LastSystemLookup	datetime,
		LastSystemUpdate	datetime
	)

	DECLARE tabl_cur CURSOR FOR
		SELECT [TABLE_SCHEMA], [TABLE_NAME]
			FROM [INFORMATION_SCHEMA].[TABLES]
		WHERE [TABLE_TYPE] = 'BASE TABLE'
		ORDER BY [TABLE_SCHEMA], [TABLE_NAME];


	------SET @DatabaseName = 'dba_db16';

	OPEN tabl_cur;

	FETCH NEXT FROM tabl_cur INTO
		@Schema, @ObjectName;

	WHILE (@@FETCH_STATUS <> -1)
		BEGIN
			SET @Cmd = '
				SELECT OBJECT_NAME(OBJECT_ID) AS ObjectName, last_user_update,
						Database_Id, Object_Id, Index_Id, User_Seeks, User_Scans, User_Lookups, User_Updates, Last_User_Seek, 
						Last_User_Scan, Last_User_Lookup, System_Seeks, System_Scans, System_Lookups, System_Updates,
						Last_System_Seek, Last_System_Scan, Last_System_Lookup, Last_System_Update
					FROM sys.dm_db_index_usage_Stats
				WHERE database_id = DB_ID( ' + '''' + '[' + DB_NAME() + ']' +'''' + ')
					AND OBJECT_ID=OBJECT_ID(' + '''' + '[' + @ObjectName + ']' + '''' + ')
			';

			PRINT @Cmd;

			INSERT INTO @Results (
				ObjectName, lastuserupdate,
				DatabaseId, ObjectIid, IndexId, UserSeeks, UuserScans, UserLookups, UserUpdates, LastUserSeek, 
				LastUserScan, LastUserLookup, SystemSeeks, SystemScans, SystemLookups, SystemUpdates,
				LastSystemSeek, LastSystemScan, LastSystemLookup, LastSystemUpdate)
			EXEC SP_EXECUTESQL @Cmd;


			FETCH NEXT FROM tabl_cur INTO
				@Schema, @ObjectName;
		END

	CLOSE tabl_cur;
	DEALLOCATE tabl_cur;

	SELECT ObjectName, lastuserupdate,
			DatabaseId, ObjectIid, IndexId, UserSeeks, UuserScans, UserLookups, UserUpdates, LastUserSeek, 
			LastUserScan, LastUserLookup, SystemSeeks, SystemScans, SystemLookups, SystemUpdates,
			LastSystemSeek, LastSystemScan, LastSystemLookup, LastSystemUpdate
		FROM @Results;

END
GO
