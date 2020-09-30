SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- ======================================================================================
-- dba19_lis_SetCreateAGListener4BuildIt
--
--
-- Calls:		None
--
-- Description:	Set up the listener.
--
--	***** Run in SQL Command Mode. *****
-- 
-- Date			Modified By			Changes
-- 01/26/2018   Aron E. Tekulsky    Initial Coding.
-- 01/26/2018   Aron E. Tekulsky    Update to Version 140.
-- 08/07/2020   Aron E. Tekulsky    Update to Version 150.
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
	SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;

	DECLARE @Cmd			nvarchar(4000)
	DECLARE @AgName			nvarchar(128)
	DECLARE @IP				varchar(15)
	DECLARE @ListenerName	nvarchar(128)
	DECLARE @PortNum		int
	DECLARE @SubNet			varchar(15)

	SET @AgName			= 'Test1AGSeeding'; -- Availability group name
	SET @ListenerName	= 'Test1AGSeeding'; -- Listener name
	SET @IP				= '192.168.1.79';
	SET @SubNet			= '255.255.255.0';
	SET @PortNum		= 1433;

-- set up the listener

	SET @Cmd = 
		'ALTER AVAILABILITY GROUP [' + @AgName + ']
			ADD LISTENER N' + '''' + @ListenerName + '''' + ' (
			WITH IP ((N' + '''' + @IP + '''' + ', N' + '''' + @SubNet + '''' + ')),
			 PORT= ' + CONVERT(varchar(5),@PortNum) + ')';

	PRINT @Cmd;

	PRINT '	GO';


END
GO
