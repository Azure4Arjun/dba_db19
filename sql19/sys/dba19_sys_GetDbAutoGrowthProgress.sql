SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- ======================================================================================
-- dba19_sys_GetDbAutoGrowthProgress
--
--
-- Calls:		None
--
-- Description:	
-- 
-- Date			Modified By			Changes
-- 12/06/2016   Aron E. Tekulsky    Initial Coding.
-- 08/25/2020   Aron E. Tekulsky    Update to Version 150.
-- ======================================================================================
--	Copyright©2001 - 2025 Aron Tekulsky.  World wide rights reserved.
--	Use of this code is free of charge but does not in any way imply transfer of 
--	Copyright ownership to the user.
--
--  This code and information are provided "AS IS" without warranty of
--  any kind, either expressed or implied, including but not limited
--  to the implied warranties of merchantability and/or fitness for a
--  particular purpose.
-- ======================================================================================
--
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;

-- This script will email DBA if a auto-grow event occurred in the last day
-- Written by: Greg Larsen 
-- Date: 10/06/2011
 
	DECLARE @bc			int;
	DECLARE @bfn		varchar(1000);
	DECLARE @DL			varchar(1000); -- email distribution list
	DECLARE @ec			int;
	DECLARE @efn		varchar(10);
	DECLARE @filename	nvarchar(1000);
	DECLARE @ReportHTML nvarchar(MAX);
	DECLARE @Subject	nvarchar (250);

	DECLARE @filegrowthtab TABLE (
		MachineNam		nvarchar(128),
		InstanceNam		nvarchar(128),
		StartTime		datetime,
		EventName		nvarchar(128),
		DatabaseName	nvarchar(128),
		FileNam			nvarchar(255),
		GrowthMB		bigint,
		DurationMS		int
	)

 
-- Set email distrubution list value
	SET @DL = 'aron.tekulsky@E-Teknologies.net'
 
-- Get the name of the current default trace
	SELECT @filename = CAST(value AS NVARCHAR(1000))
		FROM ::fn_trace_getinfo(DEFAULT)
	WHERE traceid = 1 AND property = 2;

	PRINT @filename
 
-- rip apart file name into pieces
	SET @filename = REVERSE(@filename);
	SET @bc = CHARINDEX('.',@filename);
	SET @ec = CHARINDEX('_',@filename)+1;
	SET @efn = REVERSE(SUBSTRING(@filename,1,@bc));
	SET @bfn = REVERSE(SUBSTRING(@filename,@ec,LEN(@filename)));
 
-- set filename without rollover number
	SET @filename = @bfn + @efn
 
-- Any Events Occur in the last day
	IF EXISTS (SELECT *
		           FROM ::fn_trace_gettable(@filename, DEFAULT) AS ftg 
               WHERE (EventClass = 92  -- Date File Auto-grow
                   OR EventClass = 93) -- Log File Auto-grow
                  AND StartTime > DATEADD(dy,-1,GETDATE())) 
	BEGIN -- If there are autogrows in the last day 

		INSERT INTO @filegrowthtab (
			MachineNam, InstanceNam, StartTime, EventName, 
			DatabaseName, FileNam, GrowthMB, DurationMS)
		SELECT CAST(SERVERPROPERTY('MachineName') AS NVARCHAR(128)) AS MachineNam,
			CASE 
				WHEN SERVERPROPERTY('InstanceName') IS NULL THEN ''  
				ELSE N'\' +  CAST(SERVERPROPERTY('InstanceName') AS NVARCHAR(128))  
			END AS InstanceNam,
			ftg.StartTime AS StartTime,
			te.name AS EventName, 
              DB_NAME(ftg.databaseid) AS DatabaseName, 
              Filename,
              (ftg.IntegerData*8)/1024.0 AS GrowthMB, 
               (ftg.duration/1000)  AS DurationMS
			  FROM ::fn_trace_gettable(@filename, DEFAULT) AS ftg 
					INNER JOIN sys.trace_events AS te ON ftg.EventClass = te.trace_event_id  
          WHERE (EventClass = 92  -- Date File Auto-grow
              OR EventClass = 93) -- Log File Auto-grow 
             AND StartTime > DATEADD(dy,-1,GETDATE()) -- Less than 1 day ago
          ORDER BY StartTime


		------------SET @ReportHTML =
		------------	 N'<H1>' + N'Auto-grow Events for ' + 
		------------	CAST(SERVERPROPERTY('MachineName') AS NVARCHAR(128)) + 
		------------	 + CASE WHEN SERVERPROPERTY('InstanceName') IS NULL 
		------------		THEN ''  
  ------------         ELSE N'\' +  CAST(SERVERPROPERTY('InstanceName') AS NVARCHAR(128)) 
		------------END +
	 ------------   N'</H1>' +
		------------N'<table border="1">' +
		------------N'<tr><th>Start Time</th><th>Event Name</th>' +
		------------N'<th>Database Name</th><th>File Name</th><th>Growth in MB</th>' +
		------------N'<th>Duration in MS</th></tr>' +
		------------CAST((SELECT 
  ------------            td = ftg.StartTime, '',
  ------------            td = te.name, '',
  ------------            td = DB_NAME(ftg.databaseid), '',
  ------------            td = Filename, '',
  ------------            td =(ftg.IntegerData*8)/1024.0, '', 
  ------------            td = (ftg.duration/1000) 
		------------	  FROM ::fn_trace_gettable(@filename, DEFAULT) AS ftg 
		------------	    INNER JOIN sys.trace_events AS te ON ftg.EventClass = te.trace_event_id  
  ------------        WHERE (EventClass = 92  -- Date File Auto-grow
  ------------            OR EventClass = 93) -- Log File Auto-grow 
  ------------           AND StartTime > DATEADD(dy,-1,GETDATE()) -- Less than 1 day ago
  ------------        ORDER BY StartTime  
  ------------        FOR XML PATH('tr'), TYPE 
		------------) AS NVARCHAR(MAX) ) +
	 ------------N'</table>' ;
    
 
    
    -- Build the subject line with server and instance name
		SET @Subject = 'Auto-grow Events in Last Day ' + 
                   CAST(SERVERPROPERTY('MachineName') AS NVARCHAR(128)) + 
                 + CASE WHEN SERVERPROPERTY('InstanceName') IS NULL 
                        THEN ''  
                        ELSE N'\' +  CAST(SERVERPROPERTY('InstanceName') AS NVARCHAR(128)) 
                   END 
 ------------PRINT @Subject + ' ' + @ReportHTML

    -------------- Send email to distribution list.     
    ------------EXEC msdb.dbo.sp_send_dbmail @recipients=@DL,
    ------------       @subject = @Subject,  
    ------------       @body = @ReportHTML,
    ------------       @body_format = 'HTML',
    ------------       @profile_name='myMailprofile' ;
	END; -- If there are autogrows in the last day

	SELECT MachineNam, InstanceNam, StartTime, EventName, 
			DatabaseName, FileNam, GrowthMB, DurationMS
		FROM @filegrowthtab;


END
GO
