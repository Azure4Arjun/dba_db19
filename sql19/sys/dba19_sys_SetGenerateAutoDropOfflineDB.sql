SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- ======================================================================================
-- dba19_sys_SetGenerateAutoDropOfflineDB
--
--
-- Calls:		None
--
-- Description:	Drop all off line db's.
-- 
-- Date			Modified By			Changes
-- 11/28/2016   Aron E. Tekulsky    Initial Coding.
-- 11/22/2017   Aron E. Tekulsky    Update to Version 140.
-- 08/26/2020   Aron E. Tekulsky    Update to Version 150.
-- ======================================================================================
--	Copyrightę2001 - 2025 Aron Tekulsky.  World wide rights reserved.
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

	DECLARE @Cmd	nvarchar(4000)
	DECLARE @DbName	nvarchar(128)


	DECLARE db_cur CURSOR FOR
		SELECT d.name
			FROM sys.databases d
		WHERE d.state=6 -- offline
		ORDER BY d.Name ASC;

	OPEN db_cur;

	FETCH NEXT FROM db_cur INTO
		@DbName;

	WHILE (@@FETCH_STATUS <> -1)
		BEGIN

			SET @Cmd = 'EXEC msdb.dbo.sp_delete_database_backuphistory @database_name = N' + '''' + @DbName + '''' + 
				'
				GO ' + '
				USE [master]
				GO
				DROP DATABASE [' + @DbName  + '] 
				GO
			';

			PRINT @Cmd;



			FETCH NEXT FROM db_cur INTO
				@DbName;
		END

	CLOSE db_cur;

	DEALLOCATE db_cur;

END
GO
