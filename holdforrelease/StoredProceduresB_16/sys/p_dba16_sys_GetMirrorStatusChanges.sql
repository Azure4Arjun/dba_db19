USE [dba_db16]
GO
/****** Object:  StoredProcedure [dbo].[p_dba16_sys_GetMirrorStatusChanges]    Script Date: 11/10/2010 14:42:28 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- ==============================================================================
-- p_dba16_sys_GetMirrorStatusChanges
--
-- Arguments:		@start_date nvarchar(4000)
--					@end_date nvarchar(4000)
--
-- Called BY:		None
--
-- Description:	Get a list of mirror status changes note: the dba_db_mirror_changes table in dba_db 
--						needs to be truncated before each run of this sp.
-- 
-- Date					Modified By				Changes
-- 01/21/2009   Aron E. Tekulsky		Initial Coding.
-- 04/02/2009	Aron E. Tekulsky		Change to using -31 days.  
--														also add sort to final output.
-- 10/30/2009	Aron E. Tekulsky		Add code to check for null and reset cursor.  Change to while loop.
-- 04/05/2012	Aron E. Tekulsky		Update to v100.
-- 07/27/2019	Aron E. Tekulsky		Update to v140.
-- ===============================================================================
--	Copyright©2001 - 2025 Aron Tekulsky.  World wide rights reserved.
--	Use of this code is free of charge but does not in any way imply transfer of 
--	Copyright ownership to the user.
-- ===============================================================================


CREATE PROCEDURE [dbo].[p_dba16_sys_GetMirrorStatusChanges] 
	-- Add the parameters for the stored procedure here
	@start_date nvarchar(4000), 
	@end_date nvarchar(4000)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets FROM
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED

-- define local variables
	DECLARE @hold_dbname		nvarchar(128),
			@hold_role			int,
			@hold_local_time	datetime,
			@next_dbname		nvarchar(128),
			@next_role			int,
			@next_local_time	datetime,
			@st_date			datetime,
			@ed_date			datetime
		
	SET @st_date = convert(datetime,@start_date);

-- check for nulls ON end date
    SET @ed_date = ISNULL(@end_date,@st_date);
--		SET @ed_date = dateadd(hour, 23, convert(datetime,@end_date))
--		SET @ed_date = dateadd(hour, 23, convert(datetime,@start_date))

    IF @end_date is null
-- when no end date entered we build it
		BEGIN
    		SET @ed_date = dateadd(minute, 59, @ed_date);
	        SET @ed_date = dateadd(month, 1, @ed_date);
     		SET @ed_date = dateadd(day, -31, @ed_date);
		END
--		print @st_date
--		print @ed_date
		 
		-- define the cursor
	DECLARE mir_cur CURSOR FOR
		SELECT d.name, m.role, m.local_time
			FROM msdb.dbo.dbm_monitor_data m
				JOIN sys.databases d ON (m.database_id = d.database_id)
				JOIN sys.database_mirroring a ON (m.database_id = a.database_id)
		WHERE a.mirroring_guid IS NOT NULL and
			--m.database_id = 6 and
			m.local_time >= @st_date and
			m.local_time <= @ed_date ;
			--m.local_time >= '2009-01-01 00:00:00' and
			--m.local_time <= '2009-01-20 23:59:00' ;

-- open the cursor
	OPEN mir_cur;

-- fetch the first row
	FETCH NEXT FROM mir_cur INTO
		@hold_dbname, @hold_role, @hold_local_time;
		
--	IF @hold_role is NULL
	WHILE (@hold_role is NULL)
		BEGIN
		-- table was empty.  reset and try again
	--print '@hold_role is null. we are retrying'
			CLOSE mir_cur;
			OPEN mir_cur;
			FETCH NEXT FROM mir_cur INTO
				@hold_dbname, @hold_role, @hold_local_time;

		END

	-- initial set of values so they match
	SET @next_dbname	 = @hold_dbname;
	SET @next_role		 = @hold_role;
	SET @next_local_time = @hold_local_time;
	
	--PRINT 'name ' + @hold_dbname + ' ' + convert(char(1),@hold_role) + ' ' + convert(varchar(50),@hold_local_time)
	
	-- insert values
	INSERT dba_db_mirror_changes
		(t_dbname, t_dbrole, t_db_local_time)
		VALUES 
		(@hold_dbname, @hold_role, @hold_local_time);
	
	WHILE(@@FETCH_STATUS = 0)
		BEGIN
			IF (@hold_dbname = @next_dbname AND
				@hold_role = @next_role)
				BEGIN	
-- loop and get next until no match
					FETCH NEXT FROM mir_cur INTO
						@next_dbname, @next_role, @next_local_time;
				END
			ELSE -- no match so save and reset hold
				BEGIN
	-- insert values
					INSERT dba_db_mirror_changes
						(t_dbname, t_dbrole, t_db_local_time)
					VALUES 
						(@next_dbname, @next_role, @next_local_time);
		
					--PRINT 'name2 ' + @next_dbname + ' ' + convert(char(1),@next_role)+ ' ' + convert(varchar(50),@next_local_time)
			-- hold
					SET @hold_dbname	 = @next_dbname;
					SET @hold_role		 = @next_role;
					SET @hold_local_time = @next_local_time;
				END
		END	
	
	
	-- SELECT results
	SELECT @@servername as Server, t_dbname AS instance,
				 CASE t_dbrole
						WHEN 0 THEN 'Principal'
						WHEN 1 THEN 'Mirror'
						END AS Role,
			 dba_db16.dbo.f_dba16_utl_ConvertDateTimeToStringFormatted(t_db_local_time ) AS ChgDate,
			 dba_db16.dbo.f_dba16_utl_ConvertDateTimeToStringDay(t_db_local_time ) AS ChgTime
	FROM dba_db_mirror_changes
	order by instance asc, ChgDate desc, ChgTime desc;
	
	CLOSE mir_cur;
	DEALLOCATE mir_cur;
	

END







GO
GRANT EXECUTE ON [dbo].[p_dba16_sys_GetMirrorStatusChanges] TO [db_proc_exec] AS [dbo]
GO
GRANT VIEW DEFINITION ON [dbo].[p_dba16_sys_GetMirrorStatusChanges] TO [db_proc_exec] AS [dbo]