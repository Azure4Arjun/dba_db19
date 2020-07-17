SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- ======================================================================================
-- dba16_sec_SetAlterDBPermission
--
--
-- Calls:		None
--
-- Description:	Give alter db permission.
-- 
-- *** Run in SQL CMD mode. ***
---
-- Date			Modified By			Changes
-- 10/23/2010   Aron E. Tekulsky    Initial Coding.
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

	USE [master]
	GO

	GRANT ALTER ANY DATABASE TO [myid]
	GO

END
GO
