SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- ======================================================================================
-- dba16_sys_GetSqlVersion
--
--
-- Calls:		None
--
-- Description:	Get SQL version information.
-- 
-- Date			Modified By			Changes
-- 01/30/2009   Aron E. Tekulsky    Initial Coding.
-- 10/31/2017   Aron E. Tekulsky    Update to Version 140.
-- 06/07/2019	Aron E. Tekulsky	add headers.
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

	SELECT  SERVERPROPERTY('productversion') AS ProductVersion, SERVERPROPERTY ('productlevel') AS ProductLevel, SERVERPROPERTY ('edition') AS Edition;

END
GO
