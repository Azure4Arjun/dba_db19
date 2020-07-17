SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- ======================================================================================
-- p_dba19_sys_GetCheckSumVerify
--
-- Arguments:	@update_checksum	char(1)	= 'N'
--				None
--
-- CallS:		p_dba19_sys_SetCheckSumVerify
--
-- Called BY:	None
--
-- Description:	Get a list of databases which do not have checksum set on.
-- 
-- Date			Modified By			Changes
-- 06/08/2011   Aron E. Tekulsky	Initial Coding.
-- 04/04/2012	Aron E. Tekulsky	Update to v100.
-- 03/20/2018   Aron E. Tekulsky    Update to Version 140.
-- 05/26/2020   Aron E. Tekulsky    Update to Version 150.
-- ======================================================================================
--	Copyright©2001 - 2025 Aron Tekulsky.  World wide rights reserved.
--	Use of this code is free of charge but does not in any way imply transfer of 
--	Copyright ownership to the user.
-- ======================================================================================
--
CREATE PROCEDURE p_dba19_sys_GetCheckSumVerify 
	-- Add the parameters for the stored procedure here
	@update_checksum	char(1)	= 'N'
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;

	DECLARE @dbname					nvarchar(128)
	DECLARE @recovery_desc			nvarchar(60)
	DECLARE @page_verify_opt_desc	nvarchar(60)
	
	-- get list of db's meeting requirements
	
	DECLARE db_cur CURSOR 
		FOR
			SELECT name, recovery_model_desc,page_verify_option_desc 
				FROM sys.databases
			WHERE recovery_model = 1 AND -- full
					page_verify_option <> 2 AND
					state = 0;
					--and name = 'testchecksum'; -- 0 None 1 Torn Page 2 CheckSum
				
	OPEN db_cur;
	
	FETCH NEXT FROM db_cur 
		INTO @dbname, @recovery_desc, @page_verify_opt_desc;
		
	WHILE (@@fetch_status <> -1)
		BEGIN
	
			PRINT @dbname + '-' + @recovery_desc + '-' + @page_verify_opt_desc;
		
			IF upper(@update_checksum) = 'Y'
				BEGIN
					EXEC p_dba19_sys_SetCheckSumVerify @dbname;
				END 
	
			FETCH NEXT FROM db_cur 
				INTO @dbname, @recovery_desc, @page_verify_opt_desc;
		END
		
	CLOSE db_cur;
	DEALLOCATE db_cur;

	IF @@ERROR <> 0 GOTO ErrorHandler

	RETURN 1

	ErrorHandler:
	RETURN -1 
END
GO
GRANT EXECUTE ON p_dba19_sys_GetCheckSumVerify TO [db_proc_exec] AS [dbo]
GO
