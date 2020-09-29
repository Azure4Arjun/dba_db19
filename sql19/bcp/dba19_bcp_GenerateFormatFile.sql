SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- ======================================================================================
-- dba19_bcp_GenerateFormatFile
--
--
-- Calls:		None
--
-- Description:	Generte a format file to do a BULK INSERT copmmand with.
-- 
-- Date			Modified By			Changes
-- 08/20/2020   Aron E. Tekulsky    Initial Coding.
-- 08/20/2020   Aron E. Tekulsky    Update to Version 150.
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

	DECLARE @DatabaseName	nvarchar(128)
	DECLARE @SchemaName		nvarchar(128)
	DECLARE @TableName		nvarchar(128)
	DECLARE @TerminatorChar	char(1)
	DECLARE @FmtFileName	nvarchar(128)
	DECLARE @SqlCmd			nvarchar(max)
	DECLARE @ServerName		nvarchar(128)


	-- Initialize
	SET @DatabaseName	= 'dba_db19';
	SET @SchemaName		= 'dbo';
	SET @TableName		= 'dba_database_expiration_history';
	SET @FmtFileName	= 'W:\tv\xpraid_data\temp\test.fmt';
	SET @TerminatorChar	= '|';
	SET @ServerName		=	@@SERVERNAME ;

	------PRINT @ServerName;

	SET @SqlCmd = 'bcp [' + @DatabaseName + '].[' + @SchemaName + '].[' + @TableName + ']' +
		' format nul -c -f ' + @FmtFileName + ' -t' + '"' + @TerminatorChar + '"' + ', -T -S ' + @ServerName;

	PRINT @SqlCmd;

	----EXEC SP_ExecuteSQL @SqlCmd;


END
GO
