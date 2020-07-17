SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- ======================================================================================
-- dba16_mnt_LogBackupByScript
--
--
-- Calls:		p_dba16_mnt_DoBackups
--
-- Description:	
-- 
-- Date			Modified By			Changes
-- 04/18/2012   Aron E. Tekulsky    Initial Coding.
-- 01/30/2018   Aron E. Tekulsky    Update to V140.
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

exec dba_db16.dbo.p_dba16_mnt_DoBackups 'LOG', 'USER','F:\Program Files\Microsoft SQL Server\MSSQL.1\MSSQL\BACKUP\','Y','Y'
END
GO
