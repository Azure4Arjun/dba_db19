SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- ======================================================================================
-- p_dba16_utl_GetDBCompatabilityMismatch
--
-- Arguments:	None
--				None
--
-- CallS:		None
--
-- Called BY:	None
--
-- Description:	Get a list of databses that are not up to the same compatability 
--				level as the server they are on.
-- 
-- Date			Modified By			Changes
-- 01/14/2012   Aron E. Tekulsky    Initial Coding.
-- 03/23/2018   Aron E. Tekulsky    Update to Version 140.
-- ======================================================================================
--	Copyright©2001 - 2025 Aron Tekulsky.  World wide rights reserved.
--	Use of this code is free of charge but does not in any way imply transfer of 
--	Copyright ownership to the user.
-- ======================================================================================
--
CREATE PROCEDURE p_dba16_utl_GetDBCompatabilityMismatch 
	-- Add the parameters for the stored procedure here
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
   	DECLARE @serverversion nvarchar(128)
	
	
	SET @serverversion = 
		  CASE substring(@@VERSION,patindex('% - %',@@VERSION)+3, 4 )
			WHEN LTRIM('08.0') THEN	'80'	-- SQl 2000
			WHEN LTRIM('09.0') THEN	'90'	-- SQl 2005
			WHEN LTRIM('10.5') THEN	'100'	-- SQl 2008
			WHEN LTRIM('11.0') THEN	'110'	-- SQl 2012
			WHEN LTRIM('12.0') THEN	'120'	-- SQl 2014
			WHEN LTRIM('13.0') THEN	'130'	-- SQl 2016
			WHEN LTRIM('14.0') THEN	'140'	-- SQl 2017
			ELSE '90'
			END;

	SELECT d.name, d.database_id, d.create_date, d.compatibility_level, d.state_desc, d.is_in_standby, @serverversion
		FROM sys.databases d
	WHERE d.compatibility_level <> @serverversion;

	IF @@ERROR <> 0 GOTO ErrorHandler

	RETURN 1

	ErrorHandler:
	RETURN -1 
END
GO
GRANT EXECUTE ON p_dba16_utl_GetDBCompatabilityMismatch TO [db_proc_exec] AS [dbo]
GO
