USE [master]
GO

/****** Object:  DdlTrigger [ddlsvrtrg_CREATE_DATABASE_LOG]    Script Date: 5/10/2012 1:59:21 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

-- ==============================================================
-- ddlsvrtrg_CREATE_DATABASE_LOG
--
-- Arguments:	None
--				None
--
-- Called BY:	None
--
-- Description:	Log all databse creation events in the database.
-- 
-- Date				Modified By			Changes
-- 05/10/2012   Aron E. Tekulsky	Initial Coding.
-- 05/10/2012 	Aron E. Tekulsky	Update to v100.
-- ================================================================

CREATE TRIGGER [ddlsvrtrg_CREATE_DATABASE_LOG] ON ALL SERVER

FOR CREATE_DATABASE

AS

SET NOCOUNT ON

DECLARE @xmlEventData XML

-- Capture the event data that is created

SET @xmlEventData = eventdata()

--– Insert information to a EventLog table

INSERT sox.dbo.tblDDLEventLog
	(EventTime, EventType, ServerName, DatabaseName, ObjectType, ObjectName, UserName, CommandText)
VALUES
	(
	 @xmlEventData.value('(/EVENT_INSTANCE/PostTime)[1]', 'VARCHAR(50)'),
	 @xmlEventData.value('(/EVENT_INSTANCE/EventType)[1]', 'VARCHAR(255)'),
	 CONVERT(nVARCHAR(128), @xmlEventData.query('data(/EVENT_INSTANCE/ServerName)')),
	 --@xmlEventData.value('(/EVENT_INSTANCE/ServerName)[1]', 'VARCHAR(25)'),
	 @xmlEventData.value('(/EVENT_INSTANCE/DatabaseName)[1]', 'VARCHAR(255)'),
	 @xmlEventData.value('(/EVENT_INSTANCE/ObjectType)[1]', 'VARCHAR(255)'),
	 @xmlEventData.value('(/EVENT_INSTANCE/ObjectName)[1]', 'VARCHAR(128)'),
	 @xmlEventData.value('(/EVENT_INSTANCE/UserName)[1]','nVARCHAR(128)'),
	 @xmlEventData.value('(/EVENT_INSTANCE/TSQLCommand/CommandText)[1]', 'VARCHAR(MAX)'))


GO

SET ANSI_NULLS OFF
GO

SET QUOTED_IDENTIFIER OFF
GO

ENABLE TRIGGER [ddlsvrtrg_CREATE_DATABASE_LOG] ON ALL SERVER
GO


