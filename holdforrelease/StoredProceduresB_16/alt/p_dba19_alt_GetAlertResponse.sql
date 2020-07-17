USE [DBA_DB19]
GO

/****** Object:  StoredProcedure [dbo].[p_dba19_alt_GetAlertResponse]    Script Date: 2/18/2018 10:48:38 AM ******/
DROP PROCEDURE [dbo].[p_dba19_alt_GetAlertResponse]
GO

/****** Object:  StoredProcedure [dbo].[p_dba19_alt_GetAlertResponse]    Script Date: 2/18/2018 10:48:38 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


-- ======================================================================================
-- p_dba19_alt_GetAlertResponse
--
-- Arguments:	@dbname			nvarchar(128),
--				@ErrorNumber	int,
--				@Severity		int,
--				@Msg			nvarchar(4000),
--				@SvrName		nvarchar(1000),
--				@CurrentDate	varchar(8),
--				@CurrentTime	varchar(6),
--				@instance		nvarchar(1000),
--				@JobID			int,
--				@MachineName	nvarchar(1000),
--				@MSSA			nvarchar(1000),
--				@SQLDir			nvarchar(1000),
--				@SQLLogDir		nvarchar(1000),
--				@StepCt			int,
--				@StepID			int,
--				@WMI			nvarchar(128)
--
-- CallS:		None
--
-- Called BY:	Alerts from SQL Server
--
-- Description:	Main place to get info on alerts to pass for a response scenario.
-- 
-- Date			Modified By			Changes
-- 08/26/2016   Aron E. Tekulsky    Initial Coding.
-- 02/15/2018   Aron E. Tekulsky    Update to Version 140.
-- 05/26/2020   Aron E. Tekulsky    Update to Version 150.
-- ======================================================================================
--	Copyright©2001 - 2025 Aron Tekulsky.  World wide rights reserved.
--	Use of this code is free of charge but does not in any way imply transfer of 
--	Copyright ownership to the user.
-- ======================================================================================
--
CREATE PROCEDURE [dbo].[p_dba19_alt_GetAlertResponse] 
	-- Add the parameters for the stored procedure here
	@dbname			nvarchar(128),
	@ErrorNumber	int,
    @Severity		int,
	@Msg			nvarchar(4000),
    @SvrName		nvarchar(1000),
    @CurrentDate	varchar(8),
    @CurrentTime	varchar(6),
    @instance		nvarchar(1000),
    @JobID			int,
    @MachineName	nvarchar(1000),
    @MSSA			nvarchar(1000),
    @SQLDir			nvarchar(1000),
    @SQLLogDir		nvarchar(1000),
    @StepCt			int,
    @StepID			int,
    @WMI			nvarchar(128)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;

	DECLARE @DatabaseName			nvarchar(128)
	DECLARE @ErrorMessage			nvarchar(4000)
	DECLARE @ReturnedSQLStatement	nvarchar(4000)
	--DECLARE @ErrorMessage			varchar(4000)
	DECLARE @return_value			int
	DECLARE @TheSQLStatement		nvarchar(4000)

	SET @DatabaseName = substring(@dbname,2,(len(@dbname)));

    -- Insert statements for procedure here
	IF @ErrorNumber = -1
		BEGIN
		-- parse the error message for information
			--EXEC p_dba14_alt_Set1101Error @DatabaseName
			--IF [dba_db08].[dbo].[f_dba14_ParsenRemove_SurroundingCharacter] ('''', '''', 'Processes blocked') <> ''
			IF PATINDEX('%Processes blocked%', @Msg ) <> 0
				BEGIN
					----------EXEC dbo.p_dba14_GetBlocksAndSqlEecuting @ReturnedSQLStatement;
					--EXEC	@return_value = [dbo].[p_dba14_GetBlocksAndSqlEecuting] @ReturnedSQLStatement OUTPUT
					EXEC	[dbo].[p_dba19_dig_DMGetBlocksAndSqlExecuting] @ReturnedSQLStatement OUTPUT

					SET @ErrorMessage = @ReturnedSQLStatement;

				END
			ELSE 
				BEGIN
					SET @ErrorMessage = '**** could not find anything ****' ;
				END

		END
	ELSE IF @ErrorNumber = 1101
		BEGIN
			--EXEC p_dba14_alt_Set1101Error @DatabaseName;
			EXEC p_dba19_sys_GetDBFileAllocationExpansion @DatabaseName;
		END
	ELSE IF @ErrorNumber = 1105
		BEGIN
			EXEC p_dba19_alt_Set1105Error @DatabaseName;
		END
	ELSE IF @ErrorNumber = 1205
		BEGIN
			--EXEC p_dba14_alt_Set1205Error @DatabaseName;
			EXEC p_dba19_alt_Set1105Error @DatabaseName;

		END
	ELSE IF @ErrorNumber = 9002
			BEGIN
				EXEC p_dba19_mnt_SetLogFullBackup @DatabaseName;
			END
	ELSE IF @ErrorNumber = 911421
		BEGIN
			--EXEC p_dba14_alt_Set1101Error @DatabaseName;
			EXEC p_dba19_sys_GetDBFileAllocationExpansion @DatabaseName;
		END
		ELSE
			RETURN 0;

	IF @@ERROR <> 0 
		BEGIN

	--PRINT @DatabaseName
	--PRINT ' sql code is : ' + @ErrorMessage

			IF @ErrorMessage IS NULL SET @ErrorMessage =  '**** No Error Message Generated ****' + ' ' + CONVERT(varchar(20),@ErrorNumber);

			RAISERROR (@ErrorMessage,-1,-1) WITH LOG;

			GOTO ErrorHandler;
		END
	IF @@ERROR <> 0 GOTO ErrorHandler

	RETURN 1

	ErrorHandler:
	RETURN -1 
END
GO

GRANT EXECUTE ON [dbo].[p_dba19_alt_GetAlertResponse] TO [db_proc_exec] AS [dbo]
GO


