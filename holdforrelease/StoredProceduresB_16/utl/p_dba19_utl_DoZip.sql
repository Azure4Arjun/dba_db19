USE [dba_db19]
GO
--***** Object:  StoredProcedure [dbo].[p_dba19_utl_DoZip]    Script Date: 11/05/2009 15:58:20 *****
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO

-- ======================================================================================
--p_dba19_utl_DoZip                                                     
--                                                                
--Arguments:	@zipcommand 			nvarchar(1000) -            
--				@physical_device_name	nvarchar(1000)	     	    
--				@zipflags				nvarchar(1000)				
--
--
-- Calls:		None
--
--	Called By:  p_dba19_copybackups                                   
--                                                                
-- Description: This stored procedure runs the zip for the copy of a
--				db dump.
--                                                                
-- Date			Modified By			Changes
-- 05/27/2003   Aron E. Tekulsky		Initial coding.                 
-- 10/30/2003	Aron E. Tekulsky		change variable name and move   
--													 into dba_db.		            
-- 02/24/2004	Aron E. Tekulsky		Add ex flag to use maximum      
--													compression.                    
-- 09/28/2005	Aron E. Tekulsky		change to using localhost to get
--													whatever server is running it.  
-- 09/05/2006   Aron E. Tekulsky		change @zipexe to nvarchar(4000)
-- 11/04/2009	Aron E. Tekulsky		add zip flag to allow passing of
--													flags and add flexibility. This 
--													also required a change to pass  
--													the flag in p_dba_copy_backups. 
-- 11/05/2009	Aron E. Tekulsky		add code to allow listing of zip
--													to go to file.                  
-- 01/29/2018	Aron E. Tekulsky		Update to V140.
-- ======================================================================================
--	Copyright©2001 - 2025 Aron Tekulsky.  World wide rights reserved.
--	Use of this code is free of charge but does not in any way imply transfer of 
--	Copyright ownership to the user.
-- ======================================================================================
--
CREATE PROCEDURE [dbo].[p_dba19_utl_DoZip]
 @zipcommand				nvarchar(1000), 
 @physical_device_name		nvarchar(1000),
 @zipflags					nvarchar(1000)
AS

	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;

	DECLARE @zipexe nvarchar(4000)

	IF lower(@zipflags) = '-v'
		BEGIN
-- listing out contents of zip file.
			SELECT @zipexe = '\\localhost\winzip\wzzip.exe '  + @physical_device_name + ' ' + @zipflags +  ' >' + @zipcommand 
		END
	ELSE
		BEGIN
-- create or update zip file.
			SELECT @zipexe = '\\localhost\winzip\wzzip.exe ' + @zipcommand + ' ' + @physical_device_name + ' ' + @zipflags
--			SELECT @zipexe = '\\localhost\winzip\wzzip.exe ' + @zipcommand + ' ' + @physical_device_name + ' -ex -t'
--			SELECT @zipexe = '\\usnysqlcl2\winzip\wzzip.exe ' + @zipcommand + ' ' + @physical_device_name + ' -ex -t'
--			PRINT convert(char, len(@zipexe)) + ' ' + @zipcommand + ' ' +@physical_device_name
--			PRINT convert(char, len(@zipexe)) + ' ' + @zipexe
		END

	EXEC master..xp_cmdshell @zipexe


GO
GRANT EXECUTE ON [dbo].[p_dba19_utl_DoZip] TO [db_proc_exec]