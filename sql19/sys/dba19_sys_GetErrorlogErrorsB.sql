SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- ======================================================================================
-- dba19_sys_GetErrorlogErrorsB
--
--
-- Calls:		sp_readerrorlog
--
-- Description:	Get all the error log rows with an error in them.
-- 
-- Date			Modified By			Changes
-- 02/24/2017	Aron E. Tekulsky	Initial Coding.
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

	DECLARE @Cmd nvarchar(4000)
	DECLARE @LogNum int
	DECLARE @LogMax int
	DECLARE @errorlogs TABLE (
			lognum		int null,
			errordate	datetime,
			ProcessInfo varchar(255),
			TheError	varchar(max))--,
----lognum int)

	SET @LogMax = 7;
	SET @LogNum = 0;

	WHILE (@LogNum <= @LogMax)
		BEGIN
			-- ***** Get all lines in error log that have word Error in them *****

			SET @Cmd = 'EXEC sp_readerrorlog @p1=' + convert(varchar(4),@LogNum)
				+ ', @p2=1, @p3=' + '''' + 'Error:' + '''' + ', @p4=' + '''' + ''''
			PRINT @Cmd;
		
			INSERT INTO @errorlogs
				--(LogNum, errordate, ProcessInfo, TheError)
				(errordate, ProcessInfo, TheError)
			EXEC (@Cmd);

			-- ***** Get all lines in error log that have word failed in them *****
			SET @Cmd = 'EXEC sp_readerrorlog @p1=' + convert(varchar(4),@LogNum)
				+ ', @p2=1, @p3=' + '''' + 'failed' + '''' + ', @p4=' + '''' + ''''

			PRINT @Cmd;

			INSERT INTO @errorlogs
			----(LogNum, errordate, ProcessInfo, TheError)
				( errordate, ProcessInfo, TheError)
			EXEC (@Cmd);

			-- ***** Get all lines in error log that have word Full in them *****
			SET @Cmd = 'EXEC sp_readerrorlog @p1=' + convert(varchar(4),@LogNum)
				+ ', @p2=1, @p3=' + '''' + 'full' + '''' + ', @p4=' + '''' + ''''

			PRINT @Cmd;

			INSERT INTO @errorlogs
			----(LogNum, errordate, ProcessInfo, TheError)
				( errordate, ProcessInfo, TheError)
			EXEC (@Cmd);

			--***** record the log number in the table *****
			UPDATE @errorlogs
				SET LogNum = @LogNum
			WHERE LogNum IS NULL;

			-- ***** Increment the log counter *****
			SET @LogNum = @LogNum + 1;
		END

	SELECT LogNum, errordate, ProcessInfo, TheError
		FROM @errorlogs
	ORDER BY LogNum ASC, errordate DESC;

END
GO
