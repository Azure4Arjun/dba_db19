SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- ======================================================================================
-- dba19_mnt_DelZipFiles
--
--
-- Calls:		None
--
-- Description:	
-- 
-- Date			Modified By			Changes
-- 12/21/2011   Aron E. Tekulsky    Initial Coding.
-- 01/29/2018   Aron E. Tekulsky    Update to V140.
-- 08/13/2020   Aron E. Tekulsky    Update to Version 150.
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

	DECLARE @attch		nvarchar(4000), 
			@pro_file	nvarchar(2000)
	DECLARE @cmd		nvarchar(1000)
	DECLARE @rec_ip		varchar(1000), 
			@subj		nvarchar(255)
	DECLARE @R_C		int
	DECLARE @Result		int
--	DECLARE @DateText	varchar(50)
--	DECLARE @TimeText	varchar(50)
--	DECLARE @Msg		varchar(1000)

	SET @pro_file	= 'testserver';
	SET @rec_ip		= 'jsmith@abc.com;'
--	SET @subj = 'test error files';
--	SET @attch = '\\testservers1\ssis_errors\ams_connector\test_file_error.txt;';



/* copy the files from the server */
--   EXEC @Result = xp_cmdshell '  \\192.168.1.226\restore\dbzip.zip s:\testserver2   /Y';

	SET @cmd  =  '  \\' + @@servername + '\restore\delzip.bat';

	EXEC @Result = xp_cmdshell @cmd;
--   EXEC @Result = xp_cmdshell '  \\10.10.10.55\restore\delzip.bat';

	IF @Result = 1
		BEGIN
			DECLARE @DateText as varchar(32), @TimeText as varchar(32), @Msg as varchar(512)

			SET @DateText = CONVERT(varchar(32), CURRENT_TIMESTAMP, 101);
			SET @TimeText = CONVERT(varchar(32), CURRENT_TIMESTAMP, 114);

			SET @Msg = 'There are no zip backups to delete  on ' + @@servername + ' as of ' + @DateText + ' at ' + @TimeText;

			RAISERROR (@Msg, 18, 1);
 
--            DECLARE @MsgTitle varchar(50)

--            SET @MsgTitle = @Msg + CONVERT(varchar(30), CURRENT_TIMESTAMP);
			SET @subj =  @Msg + CONVERT(varchar(30), CURRENT_TIMESTAMP);


			EXEC @R_C  = msdb.dbo.sp_send_dbmail @profile_name=@pro_file, @recipients=@rec_ip, @subject=@subj , @file_attachments=@attch ;

--            EXEC master..xp_sendmail 'myemail@xxx.com; myemail2@xxx.com', @Msg , '',
--                            NULL, NULL, NULL, @MsgTitle, NULL, FALSE, FALSE, FALSE,
--                           200, ' ', TRUE, NULL, NULL;
		END

END
GO
