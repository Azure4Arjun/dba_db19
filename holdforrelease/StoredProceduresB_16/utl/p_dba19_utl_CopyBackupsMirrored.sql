SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- ======================================================================================
-- p_dba19_utl_CopyBackupsMirrored
--
-- Arguments:	None
--				None
--
-- CallS:		None
--
-- Called BY:	pkg_dba19_zipupdbbackups
--
-- Description:	This stored procedure selects the databases to zip up and send to 
--				another server from a mirrored set of servers. 
-- 
-- Date			Modified By			Changes
-- 05/27/2003   Aron E. Tekulsky    Initial coding.                 
-- 10/30/2003			            move into dba_db.		        
-- 09/28/2005	Aron E. Tekulsky	us localhost to make it generic.
-- 08/11/2006   Aron E. Tekulsky    use table to get databases to   
--                                  include.                        
-- 09/05/2006   Aron E. Tekulsky    Add sort by group_Id to make    
--                                  sure all items for a particular 
--                                  zip are processed together.     
-- 12/01/2008	Aron E. Tekulsky	eliminate hourly.               
-- 06/08/2009   Aron E. Tekulsky    Add functionality to check for  
--                                  principal in mirrored pair only.
-- 11/04/2009	Aron E. Tekulsky	Add zipflags as variable.       
-- 01/29/2018   Aron E. Tekulsky    Update to Version 140.
-- 05/26/2020   Aron E. Tekulsky    Update to Version 150.
-- ======================================================================================
--	Copyright©2001 - 2025 Aron Tekulsky.  World wide rights reserved.
--	Use of this code is free of charge but does not in any way imply transfer of 
--	Copyright ownership to the user.
-- ======================================================================================
--
CREATE PROCEDURE p_dba19_utl_CopyBackupsMirrored 
	-- Add the parameters for the stored procedure here
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;

	DECLARE @media_set_id           int
	DECLARE @family_sequence_number tinyint
	DECLARE @media_family_id        uniqueidentifier
	DECLARE @physical_device_name   nvarchar(1000)
	DECLARE @backup_start_date      datetime
	DECLARE @backup_finish_date     datetime
	DECLARE @database_name          nvarchar(1000)
	DECLARE @zipcommand             nvarchar(1000)
	DECLARE @aron                   nvarchar(1000)
	DECLARE @mypos                  int
	DECLARE @mylen                  int
	DECLARE @source_server          nvarchar(50)
	DECLARE @source_share           nvarchar(50)
	DECLARE @source_path            nvarchar(1000)
	DECLARE	@zipflags				nvarchar(1000)

-- set zip flag values to pass
	SET @zipflags = ' -ex -t'

	DECLARE back_cursor CURSOR FOR
		SELECT a.media_set_id,
				a.family_sequence_number,
				a.media_family_id,
				a.physical_device_name,
				b.backup_start_date,
				b.backup_finish_date,
				b.database_name,
				d.source_server,
				d.source_share,
				d.source_path
			FROM msdb.dbo.backupset b
				JOIN dba_db16.dbo.dba_disaster_dblist d ON (b.database_name = d.name)
				INNER JOIN msdb.dbo.backupmediafamily a ON (b.media_set_id = a.media_set_id)
				JOIN master.sys.databases s ON (d.name = s.name)
				RIGHT OUTER JOIN master.sys.database_mirroring p ON (s.database_id = p.database_id)
		WHERE (datediff(day,b.backup_start_date,getdate()) = 0 ) AND
    		charindex('hourly',a.physical_device_name) = 0 AND
			(p.mirroring_role = 1 OR
			p.mirroring_role IS null)
        ORDER BY d.group_id ASC;

	OPEN back_cursor;

	FETCH NEXT FROM back_cursor INTO @media_set_id, @family_sequence_number, @media_family_id,
		@physical_device_name, @backup_start_date, @backup_finish_date, @database_name,
		@source_server, @source_share, @source_path

	WHILE (@@fetch_status = 0)
		BEGIN

			SELECT @mypos = charindex('BACKUP',@physical_device_name);
--        print convert(char,@mypos)

			SELECT @mylen = len(@physical_device_name) - @mypos + 1;
--        print convert(char, @mylen)

--        select @aron = '\\localhost\rs_' + substring(@physical_device_name, @mypos, @mylen )
			SELECT @aron = '\\' + @source_server + '\rs_' + substring(@physical_device_name, @mypos, @mylen );
--        print @physical_device_name
--        PRINT @aron

--        SELECT @zipcommand = '\\localhost\restore\dbzip.zip'
			SELECT @zipcommand = '\\' + @source_server + '\' + @source_share + '\' + @source_path;

--        EXEC msdb.dbo.p_dba_dozip @zipcommand, @aron
			EXEC dba_db19.dbo.p_dba19_utl_DoZip @zipcommand, @aron, @zipflags;

			FETCH NEXT FROM back_cursor INTO @media_set_id, @family_sequence_number, @media_family_id,
                   @physical_device_name, @backup_start_date, @backup_finish_date, @database_name,
                   @source_server, @source_share, @source_path;

		END

	CLOSE back_cursor;
	DEALLOCATE back_cursor;

--END

	--RETURN 0





--GO
	IF @@ERROR <> 0 GOTO ErrorHandler

	RETURN 1

	ErrorHandler:
	RETURN -1 
END
GO
GRANT EXECUTE ON p_dba19_utl_CopyBackupsMirrored TO [db_proc_exec] AS [dbo]
GO
