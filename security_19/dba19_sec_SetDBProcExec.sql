SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- ======================================================================================
-- dba19_sec_SetDBProcExec
--
--
-- Calls:		None
--
-- Description:	Set up db proc exec
--
--				*** Run in SQLCMD mode ***
-- 
-- Date			Modified By			Changes
-- 12/16/2002   Aron E. Tekulsky    Initial Coding.
-- 02/05/2018   Aron E. Tekulsky    Update to Version 140.
-- 08/13/2020   Aron E. Tekulsky    Update to Version 150.
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

	USE [dba_db16]
	GO

/****** Object:  DatabaseRole [db_proc_exec]    Script Date: 09/04/2009 09:14:59 ******/
	CREATE ROLE [db_proc_exec] AUTHORIZATION [dbo]
	GO

END
GO
