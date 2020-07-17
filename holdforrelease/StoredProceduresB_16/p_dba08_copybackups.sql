USE [dba_db08]
GO

/****** Object:  StoredProcedure [dbo].[p_dba08_copybackups]    Script Date: 11/19/2009 13:03:40 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO


CREATE            PROCEDURE [dbo].[p_dba08_copybackups]
AS
/********************************************************************/
/*  p_dba08_copybackups                                               */
/*                                                                  */
/*  Arguments:  (none.)                                             */
/*  Called By:  pkg_dba_zipupdbbackups                              */
/*                                                                  */
/* Description: This stored procedure selects the databases to zip  */
/*		        up and send to another server.                      */
/*                                                                  */
/*  Date        Modified By     Change                              */
/* 05/27/2003   Aron E. Tekulsky    Initial coding.                 */
/* 10/30/2003			    move into dba_db.		                */
/* 09/28/2005	Aron E. Tekulsky	us localhost to make it generic.*/
/* 08/11/2006   Aron E. Tekulsky    use table to get databases to   */
/*                                  include.                        */
/* 09//5/2006   Aron E. Tekulsky    Add sort by group_Id to make    */
/*                                  sure all items for a particular */
/*                                  zip are processed together.     */
/* 12/01/2008	Aron E. Tekulsky	eliminate hourly.               */
/*	11/04/2009	Aron E. Tekulsky	Add zipflags as variable.       */
/********************************************************************/

DECLARE        @media_set_id              int
DECLARE        @family_sequence_number    tinyint
DECLARE        @media_family_id           uniqueidentifier
DECLARE        @physical_device_name      nvarchar(1000)
DECLARE        @backup_start_date         datetime
DECLARE        @backup_finish_date        datetime
DECLARE        @database_name             nvarchar(1000)
DECLARE        @zipcommand                nvarchar(1000)
DECLARE        @srcsrvr                      nvarchar(1000)
DECLARE        @mypos                     int
DECLARE        @mylen                     int
DECLARE        @source_server             nvarchar(50)
DECLARE        @source_share              nvarchar(50)
DECLARE        @source_path               nvarchar(1000)
DECLARE		   @zipflags			      nvarchar(1000)

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
     JOIN dba_db08.dbo.dba_disaster_dblist d ON (b.database_name = d.name)
     INNER JOIN msdb.dbo.backupmediafamily a ON (b.media_set_id = a.media_set_id)
  where (datediff(day,b.backup_start_date,getdate()) = 0 ) AND
    	charindex('hourly',a.physical_device_name) = 0
        order by d.group_id asc

OPEN back_cursor

FETCH back_cursor INTO @media_set_id, @family_sequence_number, @media_family_id,
       @physical_device_name, @backup_start_date, @backup_finish_date, @database_name,
       @source_server, @source_share, @source_path

WHILE (@@fetch_status = 0)
    BEGIN

        select @mypos = charindex('BACKUP',@physical_device_name)
--        print convert(char,@mypos)

        select @mylen = len(@physical_device_name) - @mypos + 1
--        print convert(char, @mylen)

--        select @srcsrvr = '\\localhost\rs_' + substring(@physical_device_name, @mypos, @mylen )
        select @srcsrvr = '\\' + @source_server + '\rs_' + substring(@physical_device_name, @mypos, @mylen )
--        print @physical_device_name
--        PRINT @srcsrvr

--        SELECT @zipcommand = '\\localhost\restore\dbzip.zip'
        SELECT @zipcommand = '\\' + @source_server + '\' + @source_share + '\' + @source_path

--        EXEC msdb.dbo.p_dba_dozip @zipcommand, @srcsrvr
        EXEC dba_db08.dbo.p_dba08_dozip @zipcommand, @srcsrvr, @zipflags

        FETCH back_cursor INTO @media_set_id, @family_sequence_number, @media_family_id,
                   @physical_device_name, @backup_start_date, @backup_finish_date, @database_name,
                   @source_server, @source_share, @source_path

    END

DEALLOCATE back_cursor








GO

GRANT EXECUTE ON [dbo].[p_dba08_copybackups] TO [db_proc_exec] AS [dbo]
GO


