USE [dba_db19]
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

-- ======================================================================================
-- f_dba19_utl_GetJobId
--
--  Scalar_Function template
--
-- Arguments:	@JobName
--				None
--
-- CallS:		None
--
-- Called BY:	None
--
-- Description:	Get the job id for a SQL Agent Job.
--
-- Date			Modified By			Changes
-- 11/02/2016   Aron E. Tekulsky    Initial Coding.
-- 12/26/2017   Aron E. Tekulsky    Update to V140.
-- 05/19/2020   Aron E. Tekulsky    Update to V150.
-- ======================================================================================
--	Copyright©2001 - 2025 Aron Tekulsky.  World wide rights reserved.
--	Use of this code is free of charge but does not in any way imply transfer of 
--	Copyright ownership to the user.
-- ======================================================================================
--
CREATE FUNCTION [dbo].[f_dba19_utl_GetJobId] 
(	
	-- Add the parameters for the function here
	@JobName nvarchar(128) 
	
)
RETURNS uniqueidentifier 
AS
BEGIN 
--(
	-- Add the SELECT statement with parameter references here
	--DECLARE @cmd	nvarchar(4000)
	DECLARE @jobid   uniqueidentifier
	
	--SET @cmd = 'select j.job_id, j.name,j.enabled, j.description, a.name
	SELECT @jobid = j.job_id --, j.name,j.enabled, j.description, a.name
			FROM msdb..sysjobs j
				LEFT join msdb.dbo.syscategories a on (a.category_id = j.category_id)
	WHERE j.enabled = 1 AND
		j.name = @JobName AND j.name = @JobName;

	RETURN @jobid

--)
END

GO


