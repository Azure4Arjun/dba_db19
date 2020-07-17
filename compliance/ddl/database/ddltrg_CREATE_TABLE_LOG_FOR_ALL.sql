IF  EXISTS (SELECT * FROM sys.triggers WHERE parent_class_desc = 'DATABASE' AND name = N'ddltrg_CREATE_TABLE_LOG_FOR_ALL')
DISABLE TRIGGER [ddltrg_CREATE_TABLE_LOG_FOR_ALL] ON DATABASE

GO

--USE [gtlf]
--GO

/****** Object:  DdlTrigger [ddltrg_CREATE_TABLE_LOG_FOR_ALL]    Script Date: 05/17/2012 11:53:15 ******/
IF  EXISTS (SELECT * FROM sys.triggers WHERE parent_class_desc = 'DATABASE' AND name = N'ddltrg_CREATE_TABLE_LOG_FOR_ALL')DROP TRIGGER [ddltrg_CREATE_TABLE_LOG_FOR_ALL] ON DATABASE
GO

--USE [gtlf]
--GO

/****** Object:  DdlTrigger [ddltrg_CREATE_TABLE_LOG_FOR_ALL]    Script Date: 05/17/2012 11:53:15 ******/
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
EXEC dbo.p_sox_insert_tblddleventlog @xmlEventData;

GO

SET ANSI_NULLS OFF
GO

SET QUOTED_IDENTIFIER OFF
GO

DISABLE TRIGGER [ddltrg_CREATE_TABLE_LOG_FOR_ALL] ON DATABASE
GO

ENABLE TRIGGER [ddltrg_CREATE_TABLE_LOG_FOR_ALL] ON DATABASE
GO


