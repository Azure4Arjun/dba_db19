SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- ======================================================================================
-- p_dba19_stl_SSIGetJobErrorMessageFromSSISDB
--
-- Arguments:	@ServerName
--				None
--
-- CallS:		None
--
-- Called BY:	None
--
-- Description:	Find the job error message from the SSISDB.
-- 
-- https://dba.stackexchange.com/questions/118737/how-to-query-ssisdb-to-find-out-the-errors-in-the-packages
--
-- -- Requires sysadmin role.
--
------------------------------------------
--			Error Messages
-- Message_type		Message_desc
-- -1				Unknown
-- 120				Error
-- 110				Warning
-- 70				Information
-- 10				Pre-validate
-- 20				Post-validate
-- 30				Pre-execute
-- 40				Post-execute
-- 60				Progress
-- 50				StatusChange
-- 100				QueryCancel
-- 130				TaskFailed
-- 90				Diagnostic
-- 200				Custom
-- 140				DiagnosticEx Whenever 
--					an Execute Package task executes a child package it logs 
--					this event. The event message consists of the parameter 
--					values passed to child packages.  The value of the message
--					column for DiagnosticEx is XML text.
-- 400				NonDiagnostic
-- 80				VariableValueChanged
---------------------------------------------
--
---------------------------------------------
--						Sources
--msg_src_type	message_source_Description
-- 10			Entry APIs, such as T-SQL and CLR Stored procedures
-- 20			External process used to run package (ISServerExec.exe)
-- 30			Package-level objects
-- 40			Control Flow tasks
-- 50			Control Flow containers
-- 60			Data Flow task
--
-- Date			Modified By			Changes
-- 01/06/2020   Aron E. Tekulsky    Initial Coding.
-- 01/06/2020   Aron E. Tekulsky    Update to Version 150.
-- ======================================================================================
--	Copyright©2001 - 2025 Aron Tekulsky.  World wide rights reserved.
--	Use of this code is free of charge but does not in any way imply transfer of 
--	Copyright ownership to the user.
-- ======================================================================================
--
CREATE PROCEDURE p_dba19_stl_SSIGetJobErrorMessageFromSSISDB 
	-- Add the parameters for the stored procedure here
	@ServerName nvarchar(128) 
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;

	DECLARE @DATE		DATE
	DECLARE @DateRange	smallint
	-- Initialize
	SET @DateRange = 21;
	SET @DATE = GETDATE() - @DateRange; -- This is to restrict the data for last n days, used in ON condition 

	SELECT O.Operation_Id
		   , -- Not much of use  
		   E.Folder_Name AS Project_Name, 
		   E.Project_name AS SSIS_Project_Name, 
		   EM.Package_Name, 
		   CONVERT(DATETIME, O.start_time) AS Start_Time, 
		   CONVERT(DATETIME, O.end_time) AS End_Time, 
		   CASE
			WHEN LEN(OM.message) > 255 THEN
				SUBSTRING(OM.message,1,255)
			ELSE
				OM.message 
			END AS [Error_Message], 
		   CASE
			WHEN LEN(OM.message) > 255 THEN
				SUBSTRING(OM.message,256,255)
			END AS [Error_MessageB],
		   CASE
			WHEN LEN(OM.message) > 510 THEN
				SUBSTRING(OM.message,511,255)
			END AS [Error_MessageC],
		   CASE
			WHEN LEN(OM.message) > 765 THEN
				SUBSTRING(OM.message,765,255)
			END AS [Error_MessageD],
			LEN(OM.message) AS [Err Length],
		   EM.Event_Name, 
		   EM.Message_Source_Name AS Component_Name, 
		   EM.Subcomponent_Name AS Sub_Component_Name, 
		   E.Environment_Name,
		   CASE E.Use32BitRunTime
			   WHEN 1
			   THEN 'Yes'
			   ELSE 'NO'
		   END Use32BitRunTime, 
		   EM.Package_Path, 
		   E.Executed_as_name AS Executed_By
		FROM [SSISDB].[internal].[operations] AS O
			 INNER JOIN [SSISDB].[internal].[event_messages] AS EM ON (o.start_time >= @date) -- Restrict data by date 
																 AND (EM.operation_id = O.operation_id)
			 -- Edit: I change the alias from OMs to OM here:
			 INNER JOIN [SSISDB].[internal].[operation_messages] AS OM ON (EM.operation_id = OM.operation_id)
			 INNER JOIN [SSISDB].[internal].[executions] AS E ON (OM.Operation_id = E.EXECUTION_ID)
	WHERE OM.Message_Type = 120 -- 120 means Error 
		  AND EM.event_name = 'OnError' 
		  -- This is something i'm not sure right now but SSIS.Pipeline just adding duplicates so I'm removing it. 
		  AND ISNULL(EM.subcomponent_name, '') <> 'SSIS.Pipeline'
	ORDER BY EM.operation_id DESC;

	IF @@ERROR <> 0 GOTO ErrorHandler

	RETURN 1

	ErrorHandler:
	RETURN -1 
END
GO
GRANT EXECUTE ON p_dba19_stl_SSIGetJobErrorMessageFromSSISDB TO [db_proc_exec] AS [dbo]
GO
