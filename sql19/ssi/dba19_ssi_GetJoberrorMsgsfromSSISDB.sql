SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- ======================================================================================
-- dba19_ssi_GetJoberrorMsgsfromSSISDB
--
--
-- Calls:		None
--
-- Description:	Find the job error messae from SSISDB.
-- 
-- https://dba.stackexchange.com/questions/118737/how-to-query-ssisdb-to-find-out-the-errors-in-the-packages
--
-- Requires sysadmin role.
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
	
	END
GO
