SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- ======================================================================================
-- p_dba19_mnt_DelExpiredDB
--
-- Arguments:	None
--				None
--
-- CallS:		p_dba19_mnt_CleanUpBackupsDroppedDB
--
-- Called BY:	SQL Agent Job DBA Clean Up DB Expiration.
--
-- Description:	Delete rows from db expiration table where they no longer exist.
-- 
-- Date			Modified By			Changes
-- 09/14/2010   Aron E. Tekulsky	Initial Coding.
-- 05/04/2012	Aron E. Tekulsky	Update to v100.
-- 08/25/2016	Aron E. Tekulsky	Update to v120.
-- 08/25/2016	Aron E. Tekulsky	add call to clean up old backups for deleted
-- 02/16/2018   Aron E. Tekulsky    Update to Version 140.
-- 05/26/2020   Aron E. Tekulsky    Update to Version 150.
-- ======================================================================================
--	Copyright©2001 - 2025 Aron Tekulsky.  World wide rights reserved.
--	Use of this code is free of charge but does not in any way imply transfer of 
--	Copyright ownership to the user.
-- ======================================================================================
--
CREATE PROCEDURE p_dba19_mnt_DelExpiredDB 
	-- Add the parameters for the stored procedure here
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
    DECLARE @DbName				nvarchar(128)
	DECLARE @BackupLocation		nvarchar(2000)
	DECLARE @BackupLocation2	nvarchar(2000)

	EXEC [dbo].[p_dba19_sys_GetRegistryValue] 1,@BackupLocation OUTPUT;


	DECLARE db_cur CURSOR FOR 
		SELECT name
			FROM  dbo.dba_database_expiration 
		WHERE name NOT IN (
			SELECT name
				FROM sys.databases d);

	OPEN db_cur;

	FETCH NEXT FROM db_cur 
		INTO @DbName;

	WHILE (@@FETCH_STATUS <> -1) 
		BEGIN
			DELETE FROM  dbo.dba_database_expiration 
			WHERE name = @DbName;

			IF @@ERROR <> 0 GOTO ErrorHandler;

			PRINT @DbName;

			SET @BackupLocation2 = @BackupLocation;
			SET @BackupLocation2 = @BackupLocation2 + '\' + @DbName;


			-- clean up backup folders
			EXEC [dbo].[p_dba19_mnt_CleanUpBackupsDroppedDB] @DbName, @BackupLocation 

			FETCH NEXT FROM db_cur 
				INTO @DbName;

		END

	CLOSE db_cur;

	DEALLOCATE db_cur;

	--DELETE FROM  dbo.dba_database_expiration 
		--WHERE name NOT IN (
		--	SELECT name
		--		FROM sys.databases d)

	IF @@ERROR <> 0 GOTO ErrorHandler

	RETURN 1

	ErrorHandler:
	RETURN -1 
END
GO
GRANT EXECUTE ON p_dba19_mnt_DelExpiredDB TO [db_proc_exec] AS [dbo]
GO
