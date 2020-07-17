SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- ======================================================================================
-- p_dba16_sys_GetExpiredDB
--
-- Arguments:	None
--				None
--
-- CallS:		None
--
-- Called BY:	None
--
-- Description:	Get a list of databases that have passed their expiration dates.
-- 
-- Date			Modified By			Changes
-- 06/11/2012   Aron E. Tekulsky    Initial Coding.
-- 04/14/2012	Aron E. Tekulsky	Update to v100.
-- 03/31/2018   Aron E. Tekulsky    Update to Version 140.
-- ======================================================================================
--	Copyright©2001 - 2025 Aron Tekulsky.  World wide rights reserved.
--	Use of this code is free of charge but does not in any way imply transfer of 
--	Copyright ownership to the user.
-- ======================================================================================
--
CREATE PROCEDURE p_dba16_sys_GetExpiredDB 
	-- Add the parameters for the stored procedure here
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here

	DECLARE @now	datetime

	SET @now = getdate();


	SELECT @now AS currentdy, e.name, e.db_cr_date, e.db_expiration_date, e.db_restore_date, e.db_status, datediff(day ,e.db_expiration_date,@now) AS dys
		FROM [dbo].[dba_database_expiration] e
	WHERE e.[db_expiration_date] < @now
	ORDER BY dys DESC;


	IF @@ERROR <> 0 GOTO ErrorHandler

	RETURN 1

	ErrorHandler:
	RETURN -1 
END
GO
GRANT EXECUTE ON p_dba16_sys_GetExpiredDB TO [db_proc_exec] AS [dbo]
GO
