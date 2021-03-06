SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- ======================================================================================
-- dba16_sec_SetCrDBPermission
--
--
-- Calls:		None
--
-- Description:	Give create db permission.
-- 
-- *** Run in SQLCMD mode. ***
---
-- Date			Modified By			Changes
-- 10/28/2010   Aron E. Tekulsky    Initial Coding.
-- 02/05/2018   Aron E. Tekulsky    Update to V140.
-- ======================================================================================
--	Copyrightę2001 - 2025 Aron Tekulsky.  World wide rights reserved.
--	Use of this code is free of charge but does not in any way imply transfer of 
--	Copyright ownership to the user.
-- ======================================================================================
--
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here

	USE [master]
	GO

	GRANT CREATE ANY DATABASE TO [myid]
	GO

END
GO
