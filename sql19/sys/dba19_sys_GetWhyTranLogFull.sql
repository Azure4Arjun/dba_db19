SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- ======================================================================================
-- dba19_sys_GetWhyTranLogFull
--
--
-- Calls:		None
--
-- Description:	
-- 
-- Date			Modified By			Changes
-- 05/16/2013   Aron E. Tekulsky    Initial Coding.
-- 11/05/2017   Aron E. Tekulsky    Update to Version 140.
-- 08/26/2020   Aron E. Tekulsky    Update to Version 150.
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

	SELECT d.name, d.create_date , d.compatibility_level, d.log_reuse_wait, d.log_reuse_wait_desc 
		FROM master.sys.databases d;

END
GO
