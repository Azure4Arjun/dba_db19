SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- ======================================================================================
-- dba19_sys_SetUpdateCollationforSp
--
--
-- Calls:		None
--
-- Description:	Set the collation for SharePoint.
-- 
-- Date			Modified By			Changes
-- 11/15/2016   Aron E. Tekulsky    Initial Coding.
-- 11/22/2017   Aron E. Tekulsky    Update to Version 140.
-- 08/26/2020   Aron E. Tekulsky    Update to Version 150.
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

	DECLARE @Cmd			nvarchar(4000)
	DECLARE @Collation		nvarchar(128)
	DECLARE @DbCreateDate	datetime
	DECLARE @DbName			nvarchar(128)
	DECLARE @Toda			datetime

	SET @Toda = GETDATE();

	PRINT 'USE [master] 
	GO';

	DECLARE db_cur CURSOR FOR
		SELECT d.name, d.collation_name, d.create_date 
			FROM sys.databases d
		WHERE d.database_id > 4 AND
			d.collation_name <> 'Latin1_General_CI_AS_KS_WS' AND 
			d.name NOT IN ('dba_db05','dba_db08','dba_db12','dba_db16','dba_db19', )
			--AND DATEDIFF(day, d.create_date,@Toda) = 0
		ORDER BY d.name ASC;

	OPEN db_cur;

	FETCH NEXT FROM db_cur
		INTO
			@DbName, @Collation, @DbCreateDate;

	WHILE (@@FETCH_STATUS <> -1)
		BEGIN

			SET @Cmd = 'ALTER DATABASE [' + @DbName + '] COLLATE Latin1_General_CI_AS_KS_WS
			GO';

			PRINT @Cmd;

			FETCH NEXT FROM db_cur
				INTO
					@DbName, @Collation, @DbCreateDate;
		END

	CLOSE db_cur;

	DEALLOCATE db_cur;

END
GO
