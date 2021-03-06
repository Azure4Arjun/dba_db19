set ANSI_NULLS ON
set QUOTED_IDENTIFIER ON
GO

-- ==============================================================================
--  p_dba19_utl_CopyBackups                                               
--                                                                  
--  Arguments:  None
--       
--	Calls:		p_dba19_utl_DoZip
--
--  Called By:  pkg_dba_zipupdbbackups                              
--                                                                  
-- Description: This stored procedure selects the databases to zip  
--				up and send to another server.                      
--                                                                  
--  Date				Modified By				Change                              
-- 05/27/2003   Aron E. Tekulsky    Initial coding.                 
-- 10/30/2003						move into dba_db.		                
-- 09/28/2005	Aron E. Tekulsky	us localhost to make it generic
-- 08/11/2006   Aron E. Tekulsky    use table to get databases to   
--                                  include.                        
-- 09/05/2006   Aron E. Tekulsky    Add sort by group_Id to make sure all items for a particular 
--									zip are processed together.     
-- 04/04/2012	Aron E. Tekulsky	Update to v100.
-- 05/26/2020	Aron E. Tekulsky	Update to v150.
-- ==============================================================================
--	Copyright©2003 - 2012 Aron Tekulsky.  World wide rights reserved.
--	Use of this code is free of charge but does not in any way imply transfer of 
--	Copyright ownership to the user.
-- ===============================================================================

CREATE PROCEDURE [dbo].[p_dba19_utl_copybackups]
AS
BEGIN

	DECLARE        @media_set_id              int
	DECLARE        @family_sequence_number    tinyint
	DECLARE        @media_family_id           uniqueidentifier
	DECLARE        @physical_device_name      nvarchar(1000)
	DECLARE        @backup_start_date         datetime
	DECLARE        @backup_finish_date        datetime
	DECLARE        @database_name             nvarchar(1000)
	DECLARE        @zipcommand                nvarchar(1000)
	DECLARE        @src                       nvarchar(1000)
	DECLARE        @mypos                     int
	DECLARE        @mylen                     int
	DECLARE        @source_server             nvarchar(50)
	DECLARE        @source_share              nvarchar(50)
	DECLARE        @source_path               nvarchar(1000)

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
		 JOIN dba_db19.dbo.dba_disaster_dblist d ON (b.database_name = d.name)
		 INNER JOIN msdb.dbo.backupmediafamily a ON (b.media_set_id = a.media_set_id)
	  WHERE (datediff(day,b.backup_start_date,getdate()) = 0 )
			ORDER BY d.group_id ASC

	OPEN back_cursor

	FETCH back_cursor 
		INTO @media_set_id, @family_sequence_number, @media_family_id,
		   @physical_device_name, @backup_start_date, @backup_finish_date, @database_name,
		   @source_server, @source_share, @source_path

	WHILE (@@fetch_status = 0)
		BEGIN

			SELECT @mypos = charindex('BACKUP',@physical_device_name)
	--        print convert(char,@mypos)

			SELECT @mylen = len(@physical_device_name) - @mypos + 1
	--        print convert(char, @mylen)

	--        select @src = '\\localhost\rs_' + substring(@physical_device_name, @mypos, @mylen )
			SELECT @src = '\\' + @source_server + '\rs_' + substring(@physical_device_name, @mypos, @mylen )
	--        print @physical_device_name
	--        PRINT @src

	--        SELECT @zipcommand = '\\localhost\restore\dbzip.zip'
			SELECT @zipcommand = '\\' + @source_server + '\' + @source_share + '\' + @source_path

	--        EXEC msdb.dbo.p_dba19_dozip @zipcommand, @src
			EXEC dba_db19.dbo.p_dba19_utl_DoZip @zipcommand, @src

			FETCH back_cursor 
				INTO @media_set_id, @family_sequence_number, @media_family_id,
					   @physical_device_name, @backup_start_date, @backup_finish_date, @database_name,
					   @source_server, @source_share, @source_path

		END

	DEALLOCATE back_cursor

END




