SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- ======================================================================================
-- dba19_xev_GetXevFileLocation
--
--
-- Calls:		None
--
-- Description:	Ger the location of all XEV files.
-- 
-- Date			Modified By			Changes
-- 03/13/2020   Aron E. Tekulsky    Initial Coding.
-- 03/13/2020   Aron E. Tekulsky    Update to Version 150.
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

/****** Script for SelectTopNRows command from SSMS  ******/

	DECLARE @Cmd	nvarchar(4000)

	DECLARE @XEV_Files AS TABLE (
		EventSessionAddress	varbinary(8),
		FilePath			nvarchar(128),
		MaxFileSize			int,
		MaxRolloverFiles	int
	)

	-- load the event session address and the fle path
	INSERT INTO @XEV_Files (
		EventSessionAddress, FilePath)
	SELECT o.[event_session_address], o.[column_value]
		  FROM [msdb].[sys].[dm_xe_session_object_columns] o
		JOIN [msdb].[sys].[dm_xe_sessions] s ON (s.address = o.event_session_address )
	  WHERE o.[object_type] = 'target' 
		AND o.[object_name] = 'event_file'
		AND o.[column_id] = 0;

		--update with the max file size
	UPDATE @XEV_Files
		SET MaxFileSize = (
			SELECT o.[column_value]
				FROM [msdb].[sys].[dm_xe_session_object_columns] o
					JOIN [msdb].[sys].[dm_xe_sessions] s ON (s.address = o.event_session_address )
			WHERE o.[object_type] = 'target' 
			AND o.[object_name] = 'event_file'
			AND o.[column_id] = 1
			AND EventSessionAddress = o.event_session_address);

	-- update with the max rollover files.
	UPDATE @XEV_Files
		SET MaxRolloverFiles = (
			SELECT o.[column_value]
				FROM [msdb].[sys].[dm_xe_session_object_columns] o
					JOIN [msdb].[sys].[dm_xe_sessions] s ON (s.address = o.event_session_address )
			WHERE o.[object_type] = 'target' 
			AND o.[object_name] = 'event_file'
			AND o.[column_id] = 2
			AND EventSessionAddress = o.event_session_address);

	SELECT EventSessionAddress,	FilePath, MaxFileSize, MaxRolloverFiles
			, [dba_db16].[dbo].[f_dba16_sys_RemoveFileNameAndGetPath](FilePath)
		FROM @XEV_Files;
		

	---------- column id - 0 filename, 1 - max file size, 2 max rollover files
	----SELECT o.[event_session_address]
	----	  ,o.[column_name]
	----	  ,o.[column_id]
	----	  ,o.[column_value]
	----	  ,o.[object_type]
	----	  ,o.[object_name]
	----	  ,o.[object_package_guid]
	----  FROM [msdb].[sys].[dm_xe_session_object_columns] o
	----	JOIN [msdb].[sys].[dm_xe_sessions] s ON (s.address = o.event_session_address )
	----  WHERE o.[object_type] = 'target' 
	----	AND o.[object_name] = 'event_file'
	----	AND o.[column_id] like ('[0-2]')
	----	----AND[column_name] = 'filename'
END
GO
