SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- ======================================================================================
-- p_dba16_dba_ZipupDBBackups
--
-- Arguments:	None
--				None
--
-- CallS:		p_dba16_dba_dozip
--
-- Called BY:	pkg_dba_zipupdbbackups
--
-- Description:	This stored procedure selects the databases to zip  
--					up and send to another server.
-- 
-- Date			Modified By			Changes
-- 05/27/2003   Aron E. Tekulsky	Initial coding.                 
-- 10/30/2003	Aron E. Tekulsky	move into dba_db16.		                
-- 09/28/2005	Aron E. Tekulsky	us localhost to make it generic.
-- 08/11/2006   Aron E. Tekulsky	use table to get databases to  include.                        
-- 04/04/2012	Aron E. Tekulsky	Update to v100.
-- 06/17/2019   Aron E. Tekulsky    Update to Version 140.
-- ======================================================================================
--	Copyright©2001 - 2025 Aron Tekulsky.  World wide rights reserved.
--	Use of this code is free of charge but does not in any way imply transfer of 
--	Copyright ownership to the user.
-- ======================================================================================
--
CREATE PROCEDURE p_dba16_ZipupDBBackups 
	-- Add the parameters for the stored procedure here
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	DECLARE @aron					nvarchar(128)
	DECLARE @backup_start_date		datetime
	DECLARE @backup_finish_date		datetime
	DECLARE @database_name			nvarchar(128)
	DECLARE @family_sequence_number tinyint
	DECLARE @media_family_id		uniqueidentifier
	DECLARE @media_set_id			int
	DECLARE @mypos					int
	DECLARE @mylen					int
	DECLARE @physical_device_name	nvarchar(260)
	DECLARE @zipcommand				nvarchar(128)

--DECLARE        @dbnam			  nvarchar(128)


--select @dbnam = 'dba_db16'

-- set up the command string
	SELECT @zipcommand = ' \\localhost\restore\dbzip.zip '

	DECLARE back_cursor CURSOR FOR
		SELECT a.media_set_id,
				a.family_sequence_number,
				a.media_family_id,
				a.physical_device_name,
				b.backup_start_date,
				b.backup_finish_date,
				b.database_name
			FROM msdb.dbo.backupset b
				JOIN dba_db16.dbo.dba_disaster_dblist d ON (b.database_name = d.name)
				INNER JOIN msdb.dbo.backupmediafamily a ON (b.media_set_id = a.media_set_id)
		WHERE ((lower(a.physical_device_name) like ('%@dbnam%')));--OR
	----((lower(a.physical_device_name) like ('%faip%')))


--) and
        --(datediff(day,b.backup_start_date,getdate()) = 0 )

	OPEN back_cursor;

	FETCH back_cursor INTO @media_set_id, @family_sequence_number, @media_family_id,
		@physical_device_name, @backup_start_date, @backup_finish_date, @database_name;

	WHILE (@@fetch_status = 0)
		BEGIN

			SELECT @mypos = charindex('BACKUP',@physical_device_name);
		--        print convert(char,@mypos)

			SELECT @mylen = len(@physical_device_name) - @mypos + 1;
		--        print convert(char, @mylen)

	        SELECT @aron = '\\localhost\rs_' + substring(@physical_device_name, @mypos, @mylen );
		--        print @physical_device_name
		--        PRINT @aron

	        SELECT @zipcommand = '\\localhost\restore\dbzip.zip';

		--        EXEC msdb.dbo.p_dba08_dozip @zipcommand, @aron
	        EXEC dba_db16.dbo.p_dba16_dba_DoZip @zipcommand, @aron;

		    FETCH back_cursor INTO @media_set_id, @family_sequence_number, @media_family_id,
                   @physical_device_name, @backup_start_date, @backup_finish_date, @database_name;

		END

	CLOSE back_cursor;
	DEALLOCATE back_cursor;


	IF @@ERROR <> 0 GOTO ErrorHandler

	RETURN 1

	ErrorHandler:
	RETURN -1 
END
GO
GRANT EXECUTE ON p_dba16_ZipupDBBackups TO [db_proc_exec] AS [dbo]
GO
