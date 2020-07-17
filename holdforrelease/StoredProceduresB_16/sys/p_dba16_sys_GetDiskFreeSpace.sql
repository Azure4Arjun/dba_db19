SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- ======================================================================================
-- p_dba16_sys_GetDiskFreeSpace
--
-- Arguments:	None
--				None
--
-- CallS:		None
--
-- Called BY:	None
--
-- Description:	Find free disk space.
-- 
-- Date			Modified By			Changes
-- 07/18/2008   Aron E. Tekulsky    Initial Coding.
-- 04/19/2012	Aron E. Tekulsky	Update to v100.
-- 03/31/2018   Aron E. Tekulsky    Update to Version 140.
-- ======================================================================================
--	Copyright©2001 - 2025 Aron Tekulsky.  World wide rights reserved.
--	Use of this code is free of charge but does not in any way imply transfer of 
--	Copyright ownership to the user.
-- ======================================================================================
--
CREATE PROCEDURE p_dba16_sys_GetDiskFreeSpace 
	-- Add the parameters for the stored procedure here
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	DECLARE @MB_Free			int,
		    @theserver			nvarchar(128),
	        @themessage			nvarchar(1000),
		    @recipients			nvarchar(2000),
			@subject			nvarchar(2000),
	        @message			nvarchar(2000),
		    @drive				char(1),
			@drive_limit		int,
			@recipient			varchar(50),
			@recipients_all		varchar(255),
			@recipients_count	int,
			@rec_ip				varchar(1000), 
			@subj				nvarchar(255),
			--@attch nvarchar(4000), 
			@body				nvarchar(4000),
			@pro_file			nvarchar(2000),
			@R_C				int,
			@DateText			varchar(50),
			@TimeText			varchar(50),
			@Msg				varchar(1000),
			@MsgTitle			varchar(50)


-- get the servername
	SELECT @theserver = @@SERVERNAME;

-- create table

	CREATE TABLE #FreeSpace(
		rownum	int identity,
		Drive	char(1), 
		MB_Free int)

-- isert drive values
	INSERT INTO #FreeSpace  
		EXEC master..xp_fixeddrives;

--	select * from #FreeSpace

-- declare cursor
	SET @recipients_count = 0;

	DECLARE recipients_cur CURSOR FOR
		SELECT  recipients FROM recipients ;

	DECLARE drive_cur CURSOR FOR
		SELECT  MB_Free, Drive FROM #FreeSpace ;
--			where rownum = @loopcnt;

	OPEN recipients_cur; 

-- fetch cursor
	FETCH NEXT FROM recipients_cur 
		INTO @recipient;

-- loop
	WHILE @@fetch_status = 0
		BEGIN

			IF @recipients_count < 1
				BEGIN
					SET @recipients_all = @recipient ;
		
				END
			ELSE 

				BEGIN
					SET @recipients_all = @recipients_all + '; ' + @recipient ;
				  
				END    

-- fetch next row
			set @recipients_count = @recipients_count + 1;

			FETCH NEXT FROM recipients_cur 
				INTO @recipient;

		END     
		       
-- open cursor
	OPEN drive_cur;

-- fetch cursor
	FETCH NEXT FROM drive_cur 
		INTO @MB_Free, @drive;

-- loop
	SELECT * FROM #FreeSpace;

	WHILE @@fetch_status = 0
		BEGIN
-- get drive limit
			SELECT @drive_limit = drive_limit
				FROM dbo.dba_drive_limits
			WHERE drive_letter = @drive;
--	print @@error

-- Free Space on C drive Less than Threshold
			IF @MB_Free < @drive_limit

				BEGIN
			--		Print 'Size1 = ' + convert(nvarchar(200), @MB_Free)

				--	select @recipients ='' + @recipients_all + ''
				--	print @recipients
             
				--	select @subject ='' + 'SERVER ' + '' + @theserver + '' + ' - Fresh Space Issue on ' + '' 
                 --		    + @drive + '' + ' Drive' + ''
                --	select @message = '' + 'Free space on ' + '' + @drive + '' + ' Drive of ' + '' + 
                --		   convert(nvarchar(200), @MB_Free) + '' + ' is less than limit of '
                --			+ '' + convert(nvarchar(200), @drive_limit) + '' + '*****' + ''

--*************************************************************************************
                /*exec msdb.dbo.sp_send_dbmail			

                    @recipients, @message, '', NULL, NULL, NULL,
                    @subject,NULL, FALSE, FALSE, FALSE,
                          200, ' ', TRUE, NULL, NULL;
				*/

					SET @pro_file  = 'myservername';
					SET @rec_ip = '' + @recipients_all + '';
					SET @subj = '' + 'SERVER ' + '' + @theserver + '' + ' - Fresh Space Issue on ' + '' 
						  + @drive + '' + ' Drive' + '';
					SELECT @message = '' + 'Free space on ' + '' + @drive + '' + ' Drive of ' + '' + 
							convert(nvarchar(200), @MB_Free) + '' + ' is less than limit of '
							+ '' + convert(nvarchar(200), @drive_limit) + '' + '*****' + '';

					EXEC @R_C  = msdb.dbo.sp_send_dbmail @profile_name=@pro_file, @recipients=@rec_ip, @subject=@subj , @body = @message;

					IF @R_C < 0

						BEGIN
	  						SET @DateText = CONVERT(varchar(32), CURRENT_TIMESTAMP, 101);
	     					SET @TimeText = CONVERT(varchar(32), CURRENT_TIMESTAMP, 114);

							SET @Msg = 'Unable to send dbmail' + @DateText + ' at ' + @TimeText;

	          				RAISERROR (@Msg, 16, 1);

							SET @MsgTitle = @Msg + CONVERT(varchar(30), CURRENT_TIMESTAMP);

						END
				End
        
	/*
	else 
            Begin
			

SET @pro_file  = 'usnypdba01'
--SET @rec_ip = ' atekulsky@iie.org;mtsyrin@iie.org;dguthrie@iie.org'
SET @rec_ip = '' + @recipients_all + ''
SET @subj = '' + 'SERVER ' + '' + @theserver + '' + ' - Fresh Space Issue on ' + '' 
                        + @drive + '' + ' Drive' + ''
select @message = '' + 'Free space on ' + '' + @drive + '' + ' Drive of ' + '' + 
                       convert(nvarchar(200), @MB_Free) + '' + ' MB ' + ' is more than limit of '
                + '' + convert(nvarchar(200), @drive_limit) + '' + ' MB ' + ''

EXEC @R_C  = msdb.dbo.sp_send_dbmail @profile_name=@pro_file, @recipients=@rec_ip, @subject=@subj , @body = @message

	IF @R_C < 0

		BEGIN
	  	        SET @DateText = CONVERT(varchar(32), CURRENT_TIMESTAMP, 101)
	     	        SET @TimeText = CONVERT(varchar(32), CURRENT_TIMESTAMP, 114)

		         SET @Msg = 'Unable to send dbmail' + @DateText + ' at ' + @TimeText
	          	        RAISERROR (@Msg, 16, 1)
 

		

		  SET @MsgTitle = @Msg + CONVERT(varchar(30), CURRENT_TIMESTAMP)

		END


            End
*/

-- fetch next row
			FETCH NEXT FROM drive_cur 
				INTO @MB_Free, @drive;

		END

	DROP TABLE #FreeSpace;

	CLOSE recipients_cur;
	DEALLOCATE recipients_cur;

	CLOSE drive_cur;
	DEALLOCATE drive_cur;

--GO

	IF @@ERROR <> 0 GOTO ErrorHandler

	RETURN 1

	ErrorHandler:
	RETURN -1 
END
GO
GRANT EXECUTE ON p_dba16_sys_GetDiskFreeSpace TO [db_proc_exec] AS [dbo]
GO
