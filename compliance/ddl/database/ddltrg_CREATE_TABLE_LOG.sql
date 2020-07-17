-- =============================================
-- ddltrg_CREATE_TABLE_LOG
--
-- Arguments:	None
--				None
--
-- Called BY:	None
--
-- Description:	Log all table creates in teh database.
-- 
-- Date				Modified By			Changes
-- 05/10/2012   Aron E. Tekulsky	Initial Coding.
-- 05/10/2012 	Aron E. Tekulsky	Update to v100.
-- =============================================

CREATE TRIGGER [ddltrg_CREATE_TABLE_LOG]
	ON DATABASE -- Create Database DDL Trigger
	FOR CREATE_TABLE -- Trigger will raise when creating a Table
AS

SET NOCOUNT ON

DECLARE @xmlEventData XML

-- Capture the event data that is created

SET @xmlEventData = eventdata()

--– Insert information to a EventLog table

INSERT INTO DDL_Trigger_Log.dbo.tblDDLEventLog
	(

	EventTime, EventType, ServerName, DatabaseName, ObjectType, ObjectName, UserName, CommandText
	)

SELECT REPLACE(CONVERT(VARCHAR(50), @xmlEventData.query(‘data(/EVENT_INSTANCE/PostTime)’)),
	‘T’, ‘ ‘),
	CONVERT(VARCHAR(15), @xmlEventData.query(‘data(/EVENT_INSTANCE/EventType)’)),
	CONVERT(VARCHAR(25), @xmlEventData.query(‘data(/EVENT_INSTANCE/ServerName)’)),
	CONVERT(VARCHAR(25), @xmlEventData.query(‘data(/EVENT_INSTANCE/DatabaseName)’)),
	CONVERT(VARCHAR(25), @xmlEventData.query(‘data(/EVENT_INSTANCE/ObjectType)’)),
	CONVERT(VARCHAR(25), @xmlEventData.query(‘data(/EVENT_INSTANCE/ObjectName)’)),
	CONVERT(VARCHAR(15), @xmlEventData.query(‘data(/EVENT_INSTANCE/UserName)’)),
	CONVERT(VARCHAR(MAX), @xmlEventData.query(‘data(/EVENT_INSTANCE/TSQLCommand/CommandText)’))

GO