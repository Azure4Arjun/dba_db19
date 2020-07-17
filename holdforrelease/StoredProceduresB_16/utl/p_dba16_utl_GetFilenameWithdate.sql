SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- ======================================================================================
-- p_dba16_utl_GetFilenameWithdate
--
-- Arguments:	@filetext		nvarchar(1000), -- text part of file name
--				@beforeafter	int = 0,     -- 0 textdate 1 datetext
--				@splitdate		int = 0,       -- 0 yyyymmdd 1 yyyy_mm_dd
--				@ymdindicator	int = 0--,    -- 0 mmddyyyy 1 yyyymmdd determine date order
--
-- CallS:		None
--
-- Called BY:	None
--
-- Description:	Get a file name with today's data appended as part of it.
-- 
-- Date			Modified By			Changes
-- 12/04/2008   Aron E. Tekulsky    Initial Coding.
-- 04/19/2012	Aron E. Tekulsky	Update to v100.
-- 03/31/2018   Aron E. Tekulsky    Update to Version 140.
-- ======================================================================================
--	Copyright©2001 - 2025 Aron Tekulsky.  World wide rights reserved.
--	Use of this code is free of charge but does not in any way imply transfer of 
--	Copyright ownership to the user.
-- ======================================================================================
--
CREATE PROCEDURE p_dba16_utl_GetFilenameWithdate 
	-- Add the parameters for the stored procedure here
	@filetext		nvarchar(1000), -- text part of file name
	@beforeafter	int = 0,     -- 0 textdate 1 datetext
	@splitdate		int = 0,       -- 0 yyyymmdd 1 yyyy_mm_dd
	@ymdindicator	int = 0--,    -- 0 mmddyyyy 1 yyyymmdd determine date orderAS
	AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	DECLARE @localfilename nvarchar(1000)
	DECLARE @localdate nvarchar(1000)
	
	IF @beforeafter is null SET @beforeafter = 0;
	IF @splitdate is null SET @beforeafter = 0;
	IF @ymdindicator is null SET @beforeafter = 0;
	
	IF @ymdindicator = 1
		BEGIN -- 1 - yyyymmdd
		---- set up the date
			IF @splitdate = 1
				BEGIN -- 1 - split date with underscores
					SET @localdate = [dbo].[f_dba16_utl_ConvertDateTimeToStringYear](getdate())   + '_' +
									 [dbo].[f_dba16_utl_ConvertDateTimeToStringMonth](getdate())  + '_' + 
									 [dbo].[f_dba16_utl_ConvertDateTimeToStringDay](getdate());
				END
								 
			ELSE -- date without split
				BEGIN
					SET @localdate = [dbo].[f_dba16_utl_ConvertDateTimeToStringYear](getdate())   + 
									 [dbo].[f_dba16_utl_ConvertDateTimeToStringMonth](getdate())  + 
									 [dbo].[f_dba16_utl_ConvertDateTimeToStringDay](getdate());
				END
		END
	ELSE -- mmddyyyy - 0
		BEGIN
			IF @splitdate = 1
				BEGIN -- 1 - split date with underscores
					SET @localdate = [dbo].[f_dba16_utl_ConvertDateTimeToStringMonth](getdate())  + '_' +
									 [dbo].[f_dba16_utl_ConvertDateTimeToStringDay](getdate())    + '_' +
									 [dbo].[f_dba16_utl_ConvertDateTimeToStringYear](getdate());
				END
								    
			ELSE -- date without split
				BEGIN
					SET @localdate = [dbo].[f_dba16_utl_ConvertDateTimeToStringMonth](getdate())  + 
									 [dbo].[f_dba16_utl_ConvertDateTimeToStringDay](getdate())    + 
									 [dbo].[f_dba16_utl_ConvertDateTimeToStringYear](getdate());
				END
		END

	IF @beforeafter = 0
		BEGIN -- 0 - textdate
			SET @localfilename = @filetext + @localdate;
		END
		
	ELSE IF @beforeafter = 1
		BEGIN -- 1 - datetext
			SET @localfilename = @localdate + @filetext;
		END
	
	--SET @newfilename = @localfilename
	SELECT  @localfilename as newfilename;
	

	IF @@ERROR <> 0 GOTO ErrorHandler

	RETURN 1

	ErrorHandler:
	RETURN -1 
END
GO
GRANT EXECUTE ON p_dba16_utl_GetFilenameWithdate TO [db_proc_exec] AS [dbo]
GO
