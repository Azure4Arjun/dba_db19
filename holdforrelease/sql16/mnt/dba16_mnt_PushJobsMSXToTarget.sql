SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- ======================================================================================
-- dba16_mnt_PushJobsMSXToTarget
--
--
-- Calls:		None
--
-- Description:	Create an output script to set up all jobs for MSX on
--				specified server.
-- 
-- Date			Modified By			Changes
-- 04/17/2018 Aron E. Tekulsky Initial Coding..
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

	SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED

	DECLARE @ServerName nvarchar(128)

	SET @ServerName = 'SERVER\INSTANCE';

	USE MSDB;
	--GO;

	SELECT ('EXEC msdb..sp_add_jobserver @job_name = ''' + name + ''',
			@server_name = ''' + @ServerName + '''')
		FROM SYSJOBS WHERE CATEGORY_ID = 103;
END
GO
