USE [sox]
GO

/****** Object:  StoredProcedure [dbo].[p_sox_get_dbcreations]    Script Date: 5/22/2012 2:20:44 PM ******/
DROP PROCEDURE [dbo].[p_sox_get_dbcreations]
GO

/****** Object:  StoredProcedure [dbo].[p_sox_get_dbcreations]    Script Date: 5/22/2012 2:20:44 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


-- =============================================
-- p_sox_get_dbcreations
--
-- Arguments:	None
--				None
--
-- Called BY:	None
--
-- Description:	Get a listing of all the database creation events that took place on the server.
-- 
-- Date			Modified By			Changes
-- 05/15/2012   Aron E. Tekulsky    Initial Coding.
-- =============================================
CREATE PROCEDURE [dbo].[p_sox_get_dbcreations] 
	-- Add the parameters for the stored procedure here
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	SELECT l.ServerName, l.DatabaseName, l.EventTime, l.EventType, l.ObjectType, l.ObjectName, l.UserName--, l.CommandText
		FROM tblDDLEventLog l
	WHERE l.EventType = 'CREATE_DATABASE'
	ORDER BY l.ServerName ASC, l.EventTime DESC

	IF @@ERROR <> 0 GOTO ErrorHandler

	RETURN 1

	ErrorHandler:
	RETURN -1 
END


GO

GRANT EXECUTE ON [dbo].[p_sox_get_dbcreations] TO [db_proc_exec] AS [dbo]
GO


