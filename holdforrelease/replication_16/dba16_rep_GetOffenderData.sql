SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- ======================================================================================
-- dba16_rep_GetOffenderData
--
--
-- Calls:		None
--
-- Description:	Search the offending table for the phrase that we need.
--
--				*** Diagnostic sterp 3. ***
--
--				Note: Replace below select with one that matches the appropriate table.
--				NOTE: Run the query in the publisher db.
--				NOTE: You may need to include more than 1 column to search for the issue.
--				NOTE: CHAR(39) is an apostrophe.
-- 
-- Date			Modified By			Changes
-- 07/20/2018   Aron E. Tekulsky    Initial Coding.
-- 07/20/2018   Aron E. Tekulsky    Update to Version 140.
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

-- search all of the character columns for the offending value.
	DECLARE @CMD		nvarchar(4000)
	DECLARE @DBName		nvarchar(128)
	DECLARE @TableName	nvarchar(128)
	DECLARE @ColumnName	nvarchar(128)

	SET @DBName		= 'dba_db16_repl';
	SET @TableName	= 'dba_database_expiration'
	SET @ColumnName = 'db_application_name'
	

	SET @CMD = 'USE [' + @DBName + ']

	SELECT *
		FROM [dbo].[' + @TableName + ']
	WHERE CHARINDEX(CHAR(39),[' + @ColumnName + ']) > 0;';

	print @CMD;


	EXEC(@CMD);

END
GO
