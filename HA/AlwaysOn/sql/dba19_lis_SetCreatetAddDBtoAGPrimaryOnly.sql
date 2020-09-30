SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- ======================================================================================
-- dba19_lis_SetCreatetAddDBtoAGPrimaryOnly
--
--
-- Calls:		None
--
-- Description:	Add the db to the AG on the primary only.
--				1 Make sure db is in full recovery mode.
--				2 Make sure a full backup has already been
--				taken right before adding it to the AG.
-- 
-- Date			Modified By			Changes
-- 02/14/2019   Aron E. Tekulsky    Initial Coding.
-- 02/16/2019   Aron E. Tekulsky    Update to Version 140.
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

	DECLARE @AGName nvarchar(128)
	DECLARE @Cmd	nvarchar(4000)
	DECLARE @DBName nvarchar(128)

	SET @DBName = 'MyDBName';
	SET @AGName = 'MYAGName';

	-- Connect to the server instance that hosts the primary replica.
	-- Add an existing database to the availability group.
	SET @Cmd = 'USE [MASTER] ' +
	' ALTER AVAILABILITY GROUP ' + @AGName + ' ADD DATABASE ' + @DBName;

	PRINT @Cmd;

	EXEC(@Cmd);

END
GO
