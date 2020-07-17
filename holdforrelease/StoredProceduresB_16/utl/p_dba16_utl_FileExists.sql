SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- ======================================================================================
-- p_dba16_utl_FileExists
--
-- Arguments:	None
--				None
--
-- CallS:		None
--
-- Called BY:	None
--
-- Description:	Check to see if a file exists.
-- 
-- Date			Modified By			Changes
-- 02/28/2012   Aron E. Tekulsky    Initial Coding.
--				0 - no
--				1 - yes
-- 04/03/2012	Aron E. Tekulsky	Update to v100.
-- 03/18/2018   Aron E. Tekulsky    Update to Version 140.
-- ======================================================================================
--	Copyright©2001 - 2025 Aron Tekulsky.  World wide rights reserved.
--	Use of this code is free of charge but does not in any way imply transfer of 
--	Copyright ownership to the user.
-- ======================================================================================
--
CREATE PROCEDURE p_dba16_utl_FileExists 
	-- Add the parameters for the stored procedure here
	@filename nvarchar(2000)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	DECLARE @Result int

--	 SET @result = select dba_db.dbo.f_dba_file_exists(@filename) 

	EXEC master.DBO.xp_fileexist @filename, @Result OUTPUT

--	SELECT @Result as aron

	IF @Result = 0
	BEGIN
		RETURN -1
	END

	IF @@ERROR <> 0 GOTO ErrorHandler

	RETURN 1

	ErrorHandler:
	RETURN -1 
END
GO
GRANT EXECUTE ON p_dba16_utl_FileExists TO [db_proc_exec] AS [dbo]
GO
