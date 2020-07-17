SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- ======================================================================================
-- dba16_sys_SetManualAlwaysOnFailover
--
--
-- Calls:		None
--
-- Description:	
-- 
-- Date			Modified By			Changes
-- 02/17/2016   Aron E. Tekulsky    Initial Coding.
-- 03/17/2018   Aron E. Tekulsky    Update to V140.
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

	DECLARE @AgName	nvarchar(128)
	DECLARE @Cmd	nvarchar(4000)

	SET @AgName = 'AccountsAG';

	-- issue commnd to manually failovr the db's.
	SET @Cmd = 'ALTER AVAILABILITY GROUP ' + @AgName + ' FORCE_FAILOVER_ALLOW_DATA_LOSS;' ;

	PRINT @Cmd;

END
GO
