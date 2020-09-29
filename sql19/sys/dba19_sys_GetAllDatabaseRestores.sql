SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- ======================================================================================
-- dba19_sys_GetAllDatabaseRestores
--
--
-- Calls:		None
--
-- Description:	Stealth Edition.Get a listing of restored done on all databases.
-- 
-- Date			Modified By			Changes
-- 10/08/2009   Aron E. Tekulsky    Initial Coding.
-- 04/19/2012	Aron E. Tekulsky	Update to v100.
-- 07/27/2019	Aron E. Tekulsky	Update to v140.
-- 04/16/2020   Aron E. Tekulsky    Update to V150.
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

	DECLARE @cmd			nvarchar(2000)
	DECLARE @server_name	nvarchar(126)

	DECLARE @restore_hist TABLE (
		servername					varchar(128),
		restore_history_id			int,
		restore_date				datetime,
		destination_database_name	nvarchar(128),
		user_name					nvarchar(128),
		backup_set_id				int,
		restore_type				char(1),
		replace						bit,
		recovery					bit,
		restart						bit,
		stop_at						datetime,
		device_count				tinyint,
		stop_at_mark_name			nvarchar(128),
		stop_before					bit)

	
-- Initialize
	SET @server_name = @@servername;

    -- Insert statements for procedure here
	SET @cmd = 'SELECT ''' + @server_name + ''' AS servername, h.restore_history_id, h.restore_date, h.destination_database_name, h.user_name, h.backup_set_id,
						h.restore_type, h.replace, h.recovery, h.restart, h.stop_at, h.device_count, h.stop_at_mark_name,
						h.stop_before
					FROM [' + @server_name + '].msdb.dbo.restorehistory h
				ORDER BY h.destination_database_name ASC, restore_date DESC';
	
	INSERT INTO @restore_hist
		EXEC (@cmd);
		
	SELECT servername, restore_history_id, restore_date, destination_database_name, user_name,
			backup_set_id, restore_type, replace, recovery, restart, stop_at, device_count,
			stop_at_mark_name, stop_before
		FROM @restore_hist;

END
GO
