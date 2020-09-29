SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- ======================================================================================
-- dba19_sys_GetErrorlogErrors
--
--
-- Calls:		None
--
-- Description:	Get all the error log rows with an error in them.
-- 
-- Date			Modified By			Changes
-- 08/26/2017   Aron E. Tekulsky    Initial Coding.
-- 08/26/2017   Aron E. Tekulsky    Update to Version 140.
-- 08/25/2020   Aron E. Tekulsky    Update to Version 150.
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

	DECLARE @Cmd		nvarchar(4000)
	DECLARE @LogNum		int
	DECLARE @LogMax		int

	DECLARE @errorlogs TABLE (
			lognum		int,
			errordate	datetime,
			ProcessInfo	varchar(255),
			TheError	varchar(max))

	SET @LogMax = 13;

	SET @LogNum = 0;
	
	WHILE (@LogNum <= (@LogMax - 1))
		BEGIN

--***** Get all lines that have word Error in them *****

			SET @Cmd = 'EXEC sp_readerrorlog @p1='  + convert(varchar(4),@LogNum) + ', @p2=1, @p3=' + '''' + 'Error:' + '''' + ', @p4=' + ''''  + '''' 
			
			PRINT @CMD;

			INSERT INTO @errorlogs
				(errordate, ProcessInfo, TheError)
				EXEC(@CMD);

	IF @@ERROR <> 0 GOTO ErrorHandler

--***** Get all lines that have word Failed in them *****

			SET @Cmd = 'EXEC sp_readerrorlog @p1='  + convert(varchar(4),@LogNum) + ', @p2=1, @p3=' + '''' + 'failed' + ''''  + ', @p4=' + ''''  + ''''
			
			PRINT @CMD;

			INSERT INTO @errorlogs
				(errordate, ProcessInfo, TheError)
				EXEC(@CMD);

	IF @@ERROR <> 0 GOTO ErrorHandler


--***** Get all lines that have word Full in them *****

			SET @Cmd = 'EXEC sp_readerrorlog @p1='  + convert(varchar(4),@LogNum) + ', @p2=1, @p3=' + '''' + 'full' + ''''  + ', @p4=' + ''''  + ''''
			
			PRINT @CMD;

			INSERT INTO @errorlogs
				(errordate, ProcessInfo, TheError)
				EXEC(@CMD);

	IF @@ERROR <> 0 GOTO ErrorHandler

			UPDATE @errorlogs
				SET lognum = @LogNum
			WHERE lognum IS NULL;
			
--***** Increment log counter *****
			SET @LogNum = @LogNum + 1;

		END

	ErrorHandler:

	SELECT lognum, errordate, ProcessInfo, TheError
		FROM @errorlogs 
	ORDER BY lognum ASC, errordate DESC;

	--------GOTO theend;


END
GO
