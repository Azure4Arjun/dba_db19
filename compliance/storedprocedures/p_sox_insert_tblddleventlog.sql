/****** Object:  StoredProcedure [dbo].[p_sox_insert_tblddleventlog]    Script Date: 5/21/2012 2:49:36 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- p_sox_insert_tblddleventlog
--
-- Arguments:	@xmlEventData XML
--				None
--
-- Called BY:	ddltrg_CREATE_TABLE_LOG_FOR_ALL
--
-- Description:	Insert a row into the sox table from the ddl trigger.
-- 
-- Date			Modified By			Changes
-- 05/17/2012   Aron E. Tekulsky    Initial Coding.
-- 05/18/2012	Aron E. Tekulskly	Each user needs access to the sox db with r, w, dbprocexec.
-- =============================================
CREATE PROCEDURE [dbo].[p_sox_insert_tblddleventlog] 
	-- Add the parameters for the stored procedure here
	@xmlEventData XML
	--WITH EXECUTE AS 'soxuser'
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	INSERT INTO sox.dbo.tblDDLEventLog
		(

		EventTime, EventType, ServerName, DatabaseName, ObjectType, ObjectName, UserName, CommandText
		)

	SELECT 
		REPLACE(CONVERT(VARCHAR(50), @xmlEventData.query('data(/EVENT_INSTANCE/PostTime)')),
		'T', ' '),	CONVERT(VARCHAR(255), @xmlEventData.query('data(/EVENT_INSTANCE/EventType)')),
		CONVERT(nVARCHAR(128), @xmlEventData.query('data(/EVENT_INSTANCE/ServerName)')),
		CONVERT(VARCHAR(255), @xmlEventData.query('data(/EVENT_INSTANCE/DatabaseName)')),
		CONVERT(VARCHAR(255), @xmlEventData.query('data(/EVENT_INSTANCE/ObjectType)')),
		CONVERT(VARCHAR(128), @xmlEventData.query('data(/EVENT_INSTANCE/ObjectName)')),
		CONVERT(nVARCHAR(128), @xmlEventData.query('data(/EVENT_INSTANCE/UserName)')),
		CONVERT(VARCHAR(MAX), @xmlEventData.query('data(/EVENT_INSTANCE/TSQLCommand/CommandText)'))

	IF @@ERROR <> 0 GOTO ErrorHandler

	RETURN 1

	ErrorHandler:
	RETURN -1 
END

GO

GRANT EXECUTE ON [dbo].[p_sox_insert_tblddleventlog] TO [db_proc_exec] AS [dbo]
GO


