USE [dba_db16]
GO

/****** Object:  StoredProcedure [dbo].[p_dba19_xev_BlockedProcessReportViewerMJ]    Script Date: 3/5/2020 6:35:42 PM ******/
DROP PROCEDURE [dbo].[p_dba19_xev_BlockedProcessReportViewerMJ]
GO

/****** Object:  StoredProcedure [dbo].[p_dba19_xev_BlockedProcessReportViewerMJ]    Script Date: 3/5/2020 6:35:42 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

-- ======================================================================================
-- p_dba19_xev_BlockedProcessReportViewerMJ
--
-- Arguments:	@Source nvarchar(max)
--				@Type	varchar(10)
--
-- CallS:		None
--
-- Called BY:	p_dba19_xev_BlockedProcessReportLoadBO
--
-- Description:	
--
-- https://github.com/mjswart/sqlblockedprocesses/blob/master/sp_blocked_process_report_viewer.sql
-- 
-- Date			Modified By			Changes
-- 01/01/2020   Aron E. Tekulsky    Initial Coding.
-- 01/01/2020   Aron E. Tekulsky    Update to Version 140.
-- ======================================================================================
--	Copyright©2001 - 2025 Aron Tekulsky.  World wide rights reserved.
--	Use of this code is free of charge but does not in any way imply transfer of 
--	Copyright ownership to the user.
-- ======================================================================================
--

CREATE PROCEDURE [dbo].[p_dba19_xev_BlockedProcessReportViewerMJ]
(
	@Source nvarchar(max),
	@Type	varchar(10) = 'FILE' 
)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;



	-- Validate @Type
	IF (@Type NOT IN ('FILE', 'TABLE', 'XMLFILE', 'XESESSION'))
		RAISERROR ('The @Type parameter must be ''FILE'', ''TABLE'', ''XESESSION'' or ''XMLFILE''', 11, 1);

	IF (@Source LIKE '%.trc' AND @Type <> 'FILE')
		RAISERROR ('Warning: You specified a .trc trace. You should also specify @Type = ''FILE''', 10, 1);

	IF (@Source LIKE '%.xml' AND @Type <> 'XMLFILE')
		RAISERROR ('Warning: You specified a .xml trace. You should also specify @Type = ''XMLFILE''', 10, 1);

	IF (@Type = 'XESESSION' AND NOT EXISTS (
		SELECT * 
			FROM sys.server_event_sessions es
				JOIN sys.server_event_session_targets est ON es.event_session_id = est.event_session_id
		WHERE est.name in ('event_file', 'ring_buffer')
		  AND es.name = @Source ) 
	)
		RAISERROR ('Warning: The extended event session you supplied does not exist or does not have an "event_file" or "ring_buffer" target.', 10, 1);

	DECLARE @SQL			NVARCHAR(max);
	DECLARE @TableSource	nvarchar(max);

		

	CREATE TABLE #ReportsXML
	(
		monitorloop			nvarchar(100) NOT NULL,
		endTime				datetime NULL,
		blocking_spid		INT NOT NULL,
		blocking_ecid		INT NOT NULL,
		blocked_spid		INT NOT NULL,
		blocked_ecid		INT NOT NULL,
		blocked_hierarchy_string as CAST(blocked_spid as varchar(20)) + '.' + CAST(blocked_ecid as varchar(20)) + '/',
		blocking_hierarchy_string as CAST(blocking_spid as varchar(20)) + '.' + CAST(blocking_ecid as varchar(20)) + '/',
		bpReportXml			xml not null,
		primary key clustered (monitorloop, blocked_spid, blocked_ecid),
		unique nonclustered (monitorloop, blocking_spid, blocking_ecid, blocked_spid, blocked_ecid)
	)
	-- define source for table
	IF (@Type = 'TABLE')
		BEGIN
			-- everything input by users get quoted
			SET @TableSource = ISNULL(QUOTENAME(PARSENAME(@Source,4)) + N'.', '')
				+ ISNULL(QUOTENAME(PARSENAME(@Source,3)) + N'.', '')
				+ ISNULL(QUOTENAME(PARSENAME(@Source,2)) + N'.', '')
				+ QUOTENAME(PARSENAME(@Source,1));
		END

	-- define source for trc file
	IF (@Type = 'FILE')
		BEGIN	
			SET @TableSource = N'sys.fn_trace_gettable(N' + QUOTENAME(@Source, '''') + ', -1)';
		END

	-- load table or file
	IF (@Type IN ('TABLE', 'FILE' ))
		BEGIN
			SET @SQL = N'		
				INSERT #ReportsXML(blocked_ecid,blocked_spid,blocking_ecid,blocking_spid,
					monitorloop,bpReportXml,endTime)
				SELECT blocked_ecid,blocked_spid,blocking_ecid,blocking_spid,
						COALESCE(monitorloop, CONVERT(nvarchar(100), endTime, 120), cast(newid() as nvarchar(100))),
						bpReportXml,EndTime
					FROM ' + @TableSource + N'
						CROSS APPLY (
							SELECT CAST(TextData as xml)
							) AS bpReports(bpReportXml)
						CROSS APPLY (
							SELECT 
								monitorloop = bpReportXml.value(''(//@monitorLoop)[1]'', ''nvarchar(100)''),
								blocked_spid = bpReportXml.value(''(/blocked-process-report/blocked-process/process/@spid)[1]'', ''int''),
								blocked_ecid = bpReportXml.value(''(/blocked-process-report/blocked-process/process/@ecid)[1]'', ''int''),
								blocking_spid = bpReportXml.value(''(/blocked-process-report/blocking-process/process/@spid)[1]'', ''int''),
								blocking_ecid = bpReportXml.value(''(/blocked-process-report/blocking-process/process/@ecid)[1]'', ''int'')
							) AS bpShredded
				WHERE EventClass = 137
				  AND blocking_spid is not null
				  AND blocked_spid is not null';
		
			EXEC (@SQL);

		END 


	IF (@Type = 'XESESSION')
		BEGIN
			DECLARE @SessionType		nvarchar(max);
			DECLARE @SessionId			int;
			DECLARE @SessionTargetId	int;
			DECLARE @FilenamePattern	nvarchar(max);

			SELECT TOP ( 1 ) 
					@SessionType = est.name,
					@SessionId = est.event_session_id,
					@SessionTargetId = est.target_id
				FROM sys.server_event_sessions es
					JOIN sys.server_event_session_targets est ON es.event_session_id = est.event_session_id
			WHERE est.name in ('event_file', 'ring_buffer')
				AND es.name = @Source;

			IF (@SessionType = 'event_file')
			BEGIN
		 
				SELECT @filenamePattern = REPLACE( CAST([value] AS nvarchar(max)), '.xel', '*xel' )
					FROM sys.server_event_session_fields
				WHERE event_session_id = @SessionId
				  AND [object_id] = @SessionTargetId
				  AND name = 'filename';

				IF (@filenamePattern not like '%xel')
					set @filenamePattern += '*xel';

				INSERT #ReportsXML(blocked_ecid,blocked_spid,blocking_ecid,blocking_spid,
					monitorloop,bpReportXml,endTime)
				SELECT blocked_ecid,blocked_spid,blocking_ecid,blocking_spid,
						COALESCE(monitorloop, CONVERT(nvarchar(100), eventDate, 120), cast(newid() as nvarchar(100))),
						bpReportXml,eventDate
					FROM sys.fn_xe_file_target_read_file ( @filenamePattern, null, null, null) 
						as event_file_value
						CROSS APPLY ( SELECT CAST(event_file_value.[event_data] as xml) ) 
							as event_file_value_xml ([xml])
						CROSS APPLY (
							SELECT 
								event_file_value_xml.[xml].value('(event/@timestamp)[1]', 'datetime') as eventDate,
								event_file_value_xml.[xml].query('//event/data/value/blocked-process-report') as bpReportXml	
						) as bpReports
						CROSS APPLY (
							SELECT 
								monitorloop = bpReportXml.value('(//@monitorLoop)[1]', 'nvarchar(100)'),
								blocked_spid = bpReportXml.value('(/blocked-process-report/blocked-process/process/@spid)[1]', 'int'),
								blocked_ecid = bpReportXml.value('(/blocked-process-report/blocked-process/process/@ecid)[1]', 'int'),
								blocking_spid = bpReportXml.value('(/blocked-process-report/blocking-process/process/@spid)[1]', 'int'),
								blocking_ecid = bpReportXml.value('(/blocked-process-report/blocking-process/process/@ecid)[1]', 'int')
							) AS bpShredded
				WHERE blocking_spid is not null
				  AND blocked_spid is not null;

			END

			ELSE IF (@SessionType = 'ring_buffer')
				BEGIN
					-- get data from ring buffer
					INSERT #ReportsXML(blocked_ecid,blocked_spid,blocking_ecid,blocking_spid,
						monitorloop,bpReportXml,endTime)
					SELECT blocked_ecid,blocked_spid,blocking_ecid,blocking_spid,
							COALESCE(monitorloop, CONVERT(nvarchar(100), bpReportEndTime, 120), cast(newid() as nvarchar(100))),
							bpReportXml,bpReportEndTime
						FROM sys.dm_xe_session_targets st
							JOIN sys.dm_xe_sessions s ON s.address = st.event_session_address
							CROSS APPLY 
								( SELECT CAST(st.target_data AS XML) ) 
								AS TargetData ([xml])
							CROSS APPLY 
								TargetData.[xml].nodes('/RingBufferTarget/event[@name="blocked_process_report"]') 
								AS bpNodes(bpNode)
							CROSS APPLY 
								bpNode.nodes('./data[@name="blocked_process"]/value/blocked-process-report')
								AS bpReportXMLNodes(bpReportXMLNode)
							CROSS APPLY
								(
								  SELECT 
									bpReportXml = CAST(bpReportXMLNode.query('.') as xml),
									bpReportEndTime = bpNode.value('(./@timestamp)[1]', 'datetime'),
									monitorloop = bpReportXMLNode.value('(//@monitorLoop)[1]', 'nvarchar(100)'),
									blocked_spid = bpReportXMLNode.value('(./blocked-process/process/@spid)[1]', 'int'),
									blocked_ecid = bpReportXMLNode.value('(./blocked-process/process/@ecid)[1]', 'int'),
									blocking_spid = bpReportXMLNode.value('(./blocking-process/process/@spid)[1]', 'int'),
									blocking_ecid = bpReportXMLNode.value('(./blocking-process/process/@ecid)[1]', 'int')
								) AS bpShredded
					WHERE s.name = @Source
					OPTION (MAXDOP 1);
				END

		END



	IF (@Type = 'XMLFILE')
		BEGIN
			CREATE TABLE #TraceXML (
				id			int identity primary key,
				ReportXML	xml NOT NULL	
			)
	
			SET @SQL = N'
				INSERT #TraceXML(ReportXML)
				SELECT col FROM OPENROWSET (
						BULK ' + QUOTENAME(@Source, '''') + N', SINGLE_BLOB
					) as xmldata(col)';

			EXEC (@SQL);
	
			CREATE PRIMARY XML INDEX PXML_TraceXML ON #TraceXML(ReportXML);

			WITH XMLNAMESPACES 
			(
				'http://tempuri.org/TracePersistence.xsd' AS MY
			),
			ShreddedWheat AS 
			(
				SELECT
					bpShredded.blocked_ecid,
					bpShredded.blocked_spid,
					bpShredded.blocking_ecid,
					bpShredded.blocking_spid,
					bpShredded.monitorloop,
					bpReports.bpReportXml,
					bpReports.bpReportEndTime
				FROM #TraceXML
					CROSS APPLY 
						ReportXML.nodes('/MY:TraceData/MY:Events/MY:Event[@name="Blocked process report"]')
						AS eventNodes(eventNode)
					CROSS APPLY 
						eventNode.nodes('./MY:Column[@name="EndTime"]')
						AS endTimeNodes(endTimeNode)
					CROSS APPLY
						eventNode.nodes('./MY:Column[@name="TextData"]')
						AS bpNodes(bpNode)
					CROSS APPLY (
						SELECT CAST(bpNode.value('(./text())[1]', 'nvarchar(max)') as xml),
							CAST(LEFT(endTimeNode.value('(./text())[1]', 'varchar(max)'), 19) as datetime)
					) AS bpReports(bpReportXml, bpReportEndTime)
					CROSS APPLY (
						SELECT 
							monitorloop = bpReportXml.value('(//@monitorLoop)[1]', 'nvarchar(100)'),
							blocked_spid = bpReportXml.value('(/blocked-process-report/blocked-process/process/@spid)[1]', 'int'),
							blocked_ecid = bpReportXml.value('(/blocked-process-report/blocked-process/process/@ecid)[1]', 'int'),
							blocking_spid = bpReportXml.value('(/blocked-process-report/blocking-process/process/@spid)[1]', 'int'),
							blocking_ecid = bpReportXml.value('(/blocked-process-report/blocking-process/process/@ecid)[1]', 'int')
					) AS bpShredded
			)
			INSERT #ReportsXML(blocked_ecid,blocked_spid,blocking_ecid,blocking_spid,
				monitorloop,bpReportXml,endTime)
			SELECT blocked_ecid,blocked_spid,blocking_ecid,blocking_spid,
					COALESCE(monitorloop, CONVERT(nvarchar(100), bpReportEndTime, 120), 'unknown'),
					bpReportXml,bpReportEndTime
				FROM ShreddedWheat;
	
			DROP TABLE #TraceXML;

		END

	-- Organize and select blocked process reports
	;WITH Blockheads AS
	(
		SELECT blocking_spid, blocking_ecid, monitorloop, blocking_hierarchy_string
			FROM #ReportsXML
				EXCEPT
				SELECT blocked_spid, blocked_ecid, monitorloop, blocked_hierarchy_string
					FROM #ReportsXML
	), 
	Hierarchy AS
	(
		SELECT monitorloop, blocking_spid as spid, blocking_ecid as ecid, 
				cast('/' + blocking_hierarchy_string as varchar(max)) as chain,
				0 as level
			FROM Blockheads
	
		UNION ALL
	
		SELECT irx.monitorloop, irx.blocked_spid, irx.blocked_ecid,
				cast(h.chain + irx.blocked_hierarchy_string as varchar(max)),
				h.level+1
			FROM #ReportsXML irx
				JOIN Hierarchy h ON irx.monitorloop = h.monitorloop
					AND irx.blocking_spid = h.spid
					AND irx.blocking_ecid = h.ecid
	)
	SELECT 
			ISNULL(CONVERT(nvarchar(30), irx.endTime, 120), 
				'Lead') as traceTime,
			SPACE(4 * h.level) 
				+ CAST(h.spid as varchar(20)) 
				+ CASE h.ecid 
					WHEN 0 THEN ''
					ELSE '(' + CAST(h.ecid as varchar(20)) + ')' 
				END AS blockingTree,
			irx.bpReportXml
		FROM Hierarchy h
			LEFT JOIN #ReportsXML irx ON irx.monitorloop = h.monitorloop
				AND irx.blocked_spid = h.spid
				AND irx.blocked_ecid = h.ecid
	ORDER BY h.monitorloop, h.chain;

	DROP TABLE #ReportsXML;

	IF @@ERROR <> 0 GOTO ErrorHandler

	RETURN 1

	ErrorHandler:
	RETURN -1 
END
GO

GRANT EXECUTE ON [dbo].[p_dba19_xev_BlockedProcessReportViewerMJ] TO [db_proc_exec] AS [dbo]
GO


