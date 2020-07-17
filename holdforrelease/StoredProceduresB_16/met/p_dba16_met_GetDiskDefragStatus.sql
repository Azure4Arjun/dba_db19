SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- ======================================================================================
-- p_dba16_met_GetDiskDefragStatus
--
-- Arguments:	None
--				None
--
-- CallS:		None
--
-- Called BY:	None
--
-- Description:	Get the disk defrag analysis and update the history.
-- 
-- Date			Modified By			Changes
-- 05/25/2012   Aron E. Tekulsky    Initial Coding.
-- 06/04/2012	Aron E. Tekulsky	Update to v100.
-- 03/23/2018   Aron E. Tekulsky    Update to Version 140.
-- ======================================================================================
--	Copyright©2001 - 2025 Aron Tekulsky.  World wide rights reserved.
--	Use of this code is free of charge but does not in any way imply transfer of 
--	Copyright ownership to the user.
-- ======================================================================================
--
CREATE PROCEDURE p_dba16_met_GetDiskDefragStatus 
	-- Add the parameters for the stored procedure here
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	DECLARE @cmd			nvarchar(4000)
	DECLARE @driveletter	char(1)
	DECLARE @driveletter2	char(1)
--	DECLARE @drivespace	
	DECLARE @frag_text		varchar(4000)
	DECLARE @frag_pct		varchar(100)
	DECLARE @frag_decision  varchar(50)
	DECLARE @icount			tinyint
	DECLARE @icount2		tinyint

	CREATE TABLE #test (
		thedefrag			nvarchar(4000))

-- create tabel to store drive letters
	CREATE TABLE #FreeSpace(
		Drive				char(1), 
		MB_Free				int)

 -- get the drive letters and their space.
	INSERT INTO #FreeSpace EXEC xp_fixeddrives;

-- cursor to go through drives 1 at a atime
	DECLARE drive_cur CURSOR FOR
		SELECT substring(Drive,1,1)
			FROM #FreeSpace;

-- open the cursor
	OPEN drive_cur;

-- fetch first row
	FETCH NEXT FROM drive_cur INTO
		@driveletter;

-- loop through drives
	WHILE (@@fetch_status = 0)
		BEGIN

			SET @cmd = 'c:\windows\system32\defrag.exe -a ' + @driveletter + ':';

			PRINT 'defrag is ' + @cmd;

			INSERT INTO #test EXEC xp_cmdshell @cmd; -- this one works


			FETCH NEXT FROM drive_cur INTO
				@driveletter;

		END

	CLOSE drive_cur;
	DEALLOCATE drive_cur;

--	select *
--		from #test

	DECLARE frag_cur CURSOR FOR
		SELECT thedefrag
			FROM #test
		WHERE thedefrag is not null;

	OPEN frag_cur;

	FETCH NEXT FROM frag_cur INTO
		@frag_text;

		SET @icount = 0;
		SET @icount2 = 1;

-- parse though the file to get the information & piece it together.
	WHILE (@@fetch_status = 0)
		BEGIN
			SET @icount = @icount + 1

			IF @icount2 = 1 
				SET @driveletter2 = 'c';
			ELSE if @icount2 = 2 
				SET @driveletter2 = 'F';
			ELSE IF @icount2 = 3
				SET @driveletter2 = 'S';

			IF @icount = 4 
				BEGIN
					SET @frag_pct = @frag_text;
				END

			IF @icount = 5 
				BEGIN
					SET @frag_decision = @frag_text;

					INSERT dbo.dba_disk_fragmentation (Drive_letter, frag_pct, frag_decision)
						VALUES (@driveletter2, @frag_pct, @frag_decision);

					--UPDATE dba_db.dbo.dba_disk_fragmentation
					--	SET drive_letter	= @driveletter2,
					--		 frag_pct		= @frag_pct,
					--		 frag_decision	= @frag_decision

					SET @icount = 0;
					IF @icount2 = 3
						SET @icount2 = 1;
					ELSE
						SET @icount2 = @icount2 + 1;
				END
		

		FETCH NEXT FROM frag_cur INTO
			@frag_text;

	
	END

	SELECT TOP 3 *
		FROM dbo.dba_disk_fragmentation
		ORDER BY last_modified DESC;

	DROP TABLE  #test

	DROP TABLE #FreeSpace

	CLOSE frag_cur;
	DEALLOCATE frag_cur;


	IF @@ERROR <> 0 GOTO ErrorHandler

	RETURN 1

	ErrorHandler:
	RETURN -1 
END
GO
GRANT EXECUTE ON p_dba16_met_GetDiskDefragStatus TO [db_proc_exec] AS [dbo]
GO
