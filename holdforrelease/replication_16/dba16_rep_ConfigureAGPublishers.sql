SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- ======================================================================================
-- dba16_rep_ConfigureAGPublishers
--
--
-- Calls:		None
--
-- Description:	
--
-- https://support.hexagonsafetyinfrastructure.com/infocenter/index?page=content&id=HOW5742&actp=LIST&showDraft=false
--
-- Date			Modified By			Changes
-- 05/22/2018	Aron E. Tekulsky	Initial Coding.
-- 05/14/2019   Aron E. Tekulsky    Update to Version 140.
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

	DECLARE @Cmd NVARCHAR(4000)
	DECLARE @Comment NVARCHAR(4000)
	DECLARE @Distributor1 NVARCHAR(128)
	DECLARE @DistrDB NVARCHAR(128)
	DECLARE @DataPath NVARCHAR(128)
	DECLARE @LogPath NVARCHAR(128)
	DECLARE @LogReaderAgentAcct NVARCHAR(128)
	DECLARE @Password1 NVARCHAR(128)
	DECLARE @PubPrimary1 NVARCHAR(128)
	DECLARE @PubSecondary2 NVARCHAR(128)
	DECLARE @PublisherTypePrimary1 NVARCHAR(128)
	DECLARE @PublisherTypeSecondary2 NVARCHAR(128)
	DECLARE @ReplDataPath NVARCHAR(128)
	DECLARE @WorkingDirPrimary1 NVARCHAR(128)
	DECLARE @WorkingDirSecondary2 NVARCHAR(128)

	SET @DistrDB = 'distribution';
	SET @LogReaderAgentAcct = 'abc\logreaderacct';
	SET @PubPrimary1 = 'primarynode\instancename';
	SET @PubSecondary2 = 'secondarynode\instancename';

	PRINT '*** Turn on trace flag for Primary replica ' + @PubPrimary1 + ' *** ';
	PRINT 'Connect to ' + @PubPrimary1;

	SET @Cmd = 'DBCC TRACEON (1448,-1)';

	PRINT @Cmd;
	PRINT '*** Turn on trace flag for Secondary replica ' + @PubSecondary2 + ' *** ';
	PRINT 'Connect to ' + @PubSecondary2;
	
	SET @Cmd = 'DBCC TRACEON (1448,-1)' + CHAR(13);

	PRINT @Cmd;
	PRINT '** The login that the log reader agent runs under needs to have db_owner
		permission on the distribution and publication databases. **';
	PRINT '** The login also needs to have the Alter any linked server and Alter any
		login privileges on the Distributor instance. **';

	SET @Cmd = 'USE [distribution]
			GO ' + CHAR(13) + ' CREATE USER [' + @LogReaderAgentAcct + '] FOR LOGIN [' + @LogReaderAgentAcct + ']
			GO ' + CHAR(13) + 'USE [' + @DistrDB + ']
			GO ' + CHAR(13) + 'ALTER ROLE [db_owner] ADD MEMBER [' + @LogReaderAgentAcct + ']
			GO ' + CHAR(13);

	PRINT @Cmd;

END
GO
