SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- ======================================================================================
-- dba16_utl_CreateJoinSecondaryToAG3BuildIt
--
--
-- Calls:		None
--
-- Description:	join the Secondary replicas to the AG.
--				Note: run this on the Secondary.
--
--	***** Run in SQL Command Mode. *****
-- 
-- Date			Modified By			Changes
-- 01/26/2018   Aron E. Tekulsky    Initial Coding.
-- 01/26/2018   Aron E. Tekulsky    Update to V140.
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

	DECLARE @Cmd			nvarchar(4000)
	DECLARE @AgName			nvarchar(128)
	DECLARE @Instance2Name	nvarchar(128)
	DECLARE @NodeName2		nvarchar(128)

	SET @AgName			= 'Test1AGSeeding';
	SET @NodeName2		= 'ETEK-NODE16-2';
	SET @Instance2Name	= 'ETEKSQL16B'

-- join the Secondary replicas to the AG.
	--SET @Cmd = '	:CONNECT ' + @NodeName2 + '\' + @Instance2Name

	--PRINT @Cmd;

	SET @Cmd = 'ALTER AVAILABILITY GROUP [' + @AgName + '] JOIN -- On Secondary Replica'
	PRINT @Cmd;
	PRINT 'GO'


	SET @Cmd = 'ALTER AVAILABILITY GROUP [' + @AgName + '] GRANT CREATE ANY DATABASE'

	PRINT @Cmd;
	PRINT 'GO'

END
GO
