USE [model]
GO
/****** Object:  DdlTrigger [ddltrg_CREATE_TABLE_LOG_FOR_ALL]    Script Date: 05/23/2012 14:11:45 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


-- =============================================
-- ddltrg_CREATE_TABLE_LOG_FOR_ALL
--
-- Arguments:	None
--				None
--
-- Called BY:	None
--
-- Description:	Log all table events in the database.
-- 
-- Date				Modified By			Changes
-- 05/10/2012   Aron E. Tekulsky	Initial Coding.
-- 05/10/2012 	Aron E. Tekulsky	Update to v100.
-- 05/23/2012	Aron E. Tekulsky	update to include soxuser to execute the sp.
-- =============================================

CREATE TRIGGER [ddltrg_CREATE_TABLE_LOG_FOR_ALL]
	ON DATABASE -- Create Database DDL Trigger
	FOR DDL_DATABASE_LEVEL_EVENTS -- Trigger will raise when any Table Event occurs
AS

SET NOCOUNT ON

DECLARE @xmlEventData XML

-- Capture the event data that is created

SET @xmlEventData = eventdata()

--– Insert information to a EventLog table
	 --REPLACE(CONVERT(VARCHAR(50), @xmlEventData.query('data(/EVENT_INSTANCE/PostTime)'), 'T', ' '),

--INSERT INTO sox.dbo.tblDDLEventLog
--	(

--	EventTime, EventType, ServerName, DatabaseName, ObjectType, ObjectName, UserName, CommandText
--	)

--SELECT 
--REPLACE(CONVERT(VARCHAR(50), @xmlEventData.query('data(/EVENT_INSTANCE/PostTime)')),
--	'T', ' '),	CONVERT(VARCHAR(255), @xmlEventData.query('data(/EVENT_INSTANCE/EventType)')),
--	CONVERT(nVARCHAR(128), @xmlEventData.query('data(/EVENT_INSTANCE/ServerName)')),
--	CONVERT(VARCHAR(255), @xmlEventData.query('data(/EVENT_INSTANCE/DatabaseName)')),
--	CONVERT(VARCHAR(255), @xmlEventData.query('data(/EVENT_INSTANCE/ObjectType)')),
--	CONVERT(VARCHAR(128), @xmlEventData.query('data(/EVENT_INSTANCE/ObjectName)')),
--	CONVERT(nVARCHAR(128), @xmlEventData.query('data(/EVENT_INSTANCE/UserName)')),
--	CONVERT(VARCHAR(MAX), @xmlEventData.query('data(/EVENT_INSTANCE/TSQLCommand/CommandText)'))

--EXEC sox.dbo.p_sox_insert_tblddleventlog @xmlEventData;
EXEC AS LOGIN= 'soxuser';
EXEC sox.dbo.p_sox_insert_tblddleventlog @xmlEventData;
REVERT;



GO
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO
ENABLE TRIGGER [ddltrg_CREATE_TABLE_LOG_FOR_ALL] ON DATABASE