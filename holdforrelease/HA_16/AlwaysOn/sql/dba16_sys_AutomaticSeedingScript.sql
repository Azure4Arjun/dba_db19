SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- ======================================================================================
-- dba16_sys_AutomaticSeedingScript
--
--
-- Calls:		None
--
-- Description:	
--
--- YOU MUST EXECUTE THE FOLLOWING SCRIPT IN SQLCMD MODE.
-- 
-- Date			Modified By			Changes
-- 01/15/2018   Aron E. Tekulsky    Initial Coding.
-- 01/15/2018   Aron E. Tekulsky    Update to Version 140.
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

	DECLARE	@AgName			nvarchar(128)
	DECLARE @Cmd			nvarchar(4000)
	DECLARE @DBName			nvarchar(128)
	DECLARE	@InstanceName	nvarchar(128)
	DECLARE @PrimaryName	nvarchar(128)
	DECLARE @SecondaryName	nvarchar(128)

	SET @AgName			=	'MYAGName';
	SET @InstanceName	=	'PROD';
	SET @PrimaryName	=	'MyPrimaryName';
	SET @SecondaryName	=	'MySecondaryName';

	SET @CMD = '
:Connect MYPRIMARYServer\PROD
'
	PRINT @Cmd;

	EXEC (@Cmd);



	USE [master]
	GO

	SET @Cmd = '
	ALTER AVAILABILITY GROUP [' + @AgName + ']
		MODIFY REPLICA ON N' + '' + @PrimaryName + '\' +@InstanceName + '' + ' WITH (SEEDING_MODE = AUTOMATIC)
	GO'

	PRINT @Cmd;

	EXEC (@Cmd);

	USE [master]
	GO

	SET @Cmd = '
	ALTER AVAILABILITY GROUP [' + @AgName + ']
		ADD DATABASE [' + @DBName + '];
	GO'

	PRINT @Cmd;

	EXEC (@Cmd);

:Connect MYSECONDARYServer\PROD

	SET @Cmd = '
	ALTER AVAILABILITY GROUP [' + @AgName + '] GRANT CREATE ANY DATABASE;
	GO'

	PRINT @Cmd;

	EXEC (@Cmd);

END
GO
