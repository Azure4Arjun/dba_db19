USE [dba_db08]
GO
/****** Object:  StoredProcedure [dbo].[p_dba08_stealth_get_all_database_restores]    Script Date: 03/05/2013 12:34:21 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- ==============================================================================
-- p_dba08_stealth_get_all_database_restores
--
-- Arguments:		@server_name	nvarchar(126)
--					None
--
-- Called BY:		None
-- Calls:			None
--
-- Description:	Stealth Edition.Get a listing of restored done on all databases.
-- 
-- Date			Modified By			Changes
-- 10/08/2009   Aron E. Tekulsky    Initial Coding.
-- 04/19/2012	Aron E. Tekulsky	Update to v100.
-- ===============================================================================
--	Copyright©2009 - 2012 Aron Tekulsky.  World wide rights reserved.
--	Use of this code is free of charge but does not in any way imply transfer of 
--	Copyright ownership to the user.
-- ===============================================================================

ALTER PROCEDURE [dbo].[p_dba08_stealth_get_all_database_restores] 
		@server_name	nvarchar(126)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	DECLARE @cmd nvarchar(2000)
	
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

	
	IF @server_name IS NULL OR @server_name = ''
		SET @server_name = @@servername 

    -- Insert statements for procedure here
	SET @cmd = 'select ''' + @server_name + ''' as servername, h.restore_history_id, h.restore_date, h.destination_database_name, h.user_name, h.backup_set_id,
					h.restore_type, h.replace, h.recovery, h.restart, h.stop_at, h.device_count, h.stop_at_mark_name,
					h.stop_before
				from [' + @server_name + '].msdb.dbo.restorehistory h
				order by h.destination_database_name asc, restore_date desc'
	
	INSERT INTO @restore_hist
		EXEC (@cmd);
		
	SELECT servername, restore_history_id, restore_date, destination_database_name, user_name,
			backup_set_id, restore_type, replace, recovery, restart, stop_at, device_count,
			stop_at_mark_name, stop_before
		FROM @restore_hist

END







GO
GRANT EXECUTE ON [dbo].[p_dba08_stealth_get_all_database_restores] TO [db_proc_exec] AS [dbo]