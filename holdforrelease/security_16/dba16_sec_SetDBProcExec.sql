SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- ======================================================================================
-- dba16_sec_SetDBProcExec
--
--
-- Calls:		None
--
-- Description:	Set up db proc exec
--
-- *** Run in SQLCMD mode ***
-- 
-- Date			Modified By			Changes
-- 12/16/2002   Aron E. Tekulsky    Initial Coding.
-- 02/05/2018   Aron E. Tekulsky    Update to V140.
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

	USE [dba_db16]
	GO

/****** Object:  DatabaseRole [db_proc_exec]    Script Date: 09/04/2009 09:14:59 ******/
	CREATE ROLE [db_proc_exec] AUTHORIZATION [dbo]
	GO



END
