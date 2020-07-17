USE [sox]
GO

/****** Object:  StoredProcedure [dbo].[p_sox_get_dbevents_all_index]    Script Date: 6/29/2012 2:14:35 PM ******/
DROP PROCEDURE [dbo].[p_sox_get_dbevents_all_index]
GO

/****** Object:  StoredProcedure [dbo].[p_sox_get_dbevents_all_index]    Script Date: 6/29/2012 2:14:35 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO




-- =======================================================
-- p_sox_get_dbevents_all_index
--
-- Arguments:	None
--				None
--
-- Called BY:	None
--
-- Description:	Get a listing of all index fragmentation
--				events that took place on the server.
-- 
-- Date			Modified By			Changes
-- 05/15/2012   Aron E. Tekulsky    Initial Coding.
-- ========================================================
CREATE PROCEDURE [dbo].[p_sox_get_dbevents_all_index] 
	-- Add the parameters for the stored procedure here
	--@eventtype	varchar(255)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	SELECT l.ServerName, l.DatabaseName, l.EventTime, l.EventType, l.ObjectType, l.ObjectName, l.UserName, 
		CASE 
			WHEN charindex('REORGANIZE',[CommandText],1) > 0 THEN
				'REORGANIZE'
			WHEN charindex('REBUILD',[CommandText],1) > 0 THEN
				'REBUILD'
		END AS idx_action
--, l.CommandText
		FROM tblDDLEventLog l
	WHERE charindex('REORGANIZE',[CommandText],1) > 0 OR 
		  charindex('REBUILD',[CommandText],1) > 0
	ORDER BY l.ServerName ASC, l.DatabaseName ASC, l.EventTime DESC

	IF @@ERROR <> 0 GOTO ErrorHandler

	RETURN 1

	ErrorHandler:
	RETURN -1 
END




GO

GRANT EXECUTE ON [dbo].[p_sox_get_dbevents_all_index] TO [db_proc_exec] AS [dbo]
GO


