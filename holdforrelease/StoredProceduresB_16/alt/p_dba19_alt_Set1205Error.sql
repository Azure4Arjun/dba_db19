SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- ======================================================================================
-- p_dba19_alt_Set1205Error
--
-- Arguments:	@dbname		nvarchar(1000)
--				None
--
-- CallS:		None
--
-- Called BY:	p_dba19_alt_GetAlertResponse
--
-- Description:	
-- 
-- Date			Modified By			Changes
-- 08/29/2016   Aron E. Tekulsky    Initial Coding.
-- 08/29/2016	Aron E. Tekulsky	V120.
-- 02/17/2018   Aron E. Tekulsky    Update to Version 140.
-- 05/26/2020   Aron E. Tekulsky    Update to Version 150.
-- ======================================================================================
--	Copyright©2001 - 2025 Aron Tekulsky.  World wide rights reserved.
--	Use of this code is free of charge but does not in any way imply transfer of 
--	Copyright ownership to the user.
-- ======================================================================================
--
CREATE PROCEDURE p_dba19_alt_Set1205Error 
	-- Add the parameters for the stored procedure here
	@dbname		nvarchar(1000)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;

	SELECT @dbname--, None

	IF @@ERROR <> 0 GOTO ErrorHandler

	RETURN 1

	ErrorHandler:
	RETURN -1 
END
GO
GRANT EXECUTE ON p_dba19_alt_Set1205Error TO [db_proc_exec] AS [dbo]
GO
