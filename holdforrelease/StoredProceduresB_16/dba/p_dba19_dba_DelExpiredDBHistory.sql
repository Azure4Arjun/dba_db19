SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- ======================================================================================
-- p_dba19_mnt_DelExpiredDBHistory
--
-- Arguments:	None
--				None
--
-- CallS:		None
--
-- Called BY:	None
--
-- Description:	Delete rows from db expiration history table where they no longer exist.
-- 
-- Date			Modified By			Changes
-- 09/14/2010   Aron E. Tekulsky	Initial Coding.
-- 05/04/2012	Aron E. Tekulsky	Update to v100.
-- 03/04/2018   Aron E. Tekulsky    Update to Version 140.
-- 05/26/2020   Aron E. Tekulsky    Update to Version 150.
-- ======================================================================================
--	Copyright©2001 - 2025 Aron Tekulsky.  World wide rights reserved.
--	Use of this code is free of charge but does not in any way imply transfer of 
--	Copyright ownership to the user.
-- ======================================================================================
--
CREATE PROCEDURE p_dba19_mnt_DelExpiredDBHistory 
	-- Add the parameters for the stored procedure here
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;

	DELETE FROM  dbo.dba_database_expiration_history
		WHERE name NOT IN (
			SELECT name
				FROM sys.databases d);

	IF @@ERROR <> 0 GOTO ErrorHandler

	RETURN 1

	ErrorHandler:
	RETURN -1 
END
GO
GRANT EXECUTE ON p_dba19_mnt_DelExpiredDBHistory TO [db_proc_exec] AS [dbo]
GO
