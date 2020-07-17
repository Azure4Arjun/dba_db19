SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- ======================================================================================
-- p_dba19_alt_Set1105Error
--
-- Arguments:	@dbname		nvarchar(128)
--				None
--
-- CallS:		p_dba19_sys_GetDBFileSizes
--				p_dba19_sys_DMGetDBDiskSpaceByLogicalName
--
-- Called BY:	p_dba19_alt_GetAlertResponse
--
-- Description:	Find the database name, maximum size on the filegroup, space on
--				the drive, 80% amount and then determine if the maximum can be 
--				increased to allow the file to continue to grow.
-- 
-- Date			Modified By			Changes
-- 08/29/2016   Aron E. Tekulsky    Initial Coding.
-- 08/29/2016	Aron E. Tekulsky	V120.
-- 02/17/2018   Aron E. Tekulsky    Update to Version 140.
-- 05/26/2020   Aron E. Tekulsky    Update to Version 150.
-- ======================================================================================
--	Copyrightę2001 - 2025 Aron Tekulsky.  World wide rights reserved.
--	Use of this code is free of charge but does not in any way imply transfer of 
--	Copyright ownership to the user.
-- ======================================================================================
--
CREATE PROCEDURE p_dba19_alt_Set1105Error 
	-- Add the parameters for the stored procedure here
	@dbname		nvarchar(128)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;

	DECLARE @DbLogicalName	nvarchar(128) 

	EXEC p_dba19_sys_GetDBFileSizes @dbname;

	EXEC p_dba19_sys_DMGetDBDiskSpaceByLogicalName @DbLogicalName, @dbname;


	IF @@ERROR <> 0 GOTO ErrorHandler

	RETURN 1

	ErrorHandler:
	RETURN -1 
END
GO
GRANT EXECUTE ON p_dba19_alt_Set1105Error TO [db_proc_exec] AS [dbo]
GO
