USE [dba_db16]
GO

/****** Object:  StoredProcedure [dbo].[p_dba16_stl_StealthGetSQLServerPatchLevel]    Script Date: 11/19/2019 6:26:38 PM ******/
DROP PROCEDURE [dbo].[p_dba16_stl_StealthGetSQLServerPatchLevel]
GO

/****** Object:  StoredProcedure [dbo].[p_dba16_stl_StealthGetSQLServerPatchLevel]    Script Date: 11/19/2019 6:26:38 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO



-- ==============================================================================
-- p_dba16_stl_StealthGetSQLServerPatchLevel
--
-- Arguments:		@server_name nvarchar(126)
--					None
--
-- Called BY:		None
-- Calls:			None
--
-- Description:	check the current level of SQL Server.
-- 
-- Date			Modified By			Changes
-- 12/02/2009   Aron E. Tekulsky    Initial Coding.
-- 04/19/2012	Aron E. Tekulsky	Update to v100.
-- 07/27/2019	Aron E. Tekulsky	Update to v140.
-- ===============================================================================
--	Copyright©2001 - 2025 Aron Tekulsky.  World wide rights reserved.
--	Use of this code is free of charge but does not in any way imply transfer of 
--	Copyright ownership to the user.
-- ===============================================================================

CREATE PROCEDURE [dbo].[p_dba16_stl_StealthGetSQLServerPatchLevel] 
	-- Add the parameters for the stored procedure here
		@server_name nvarchar(126)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
    DECLARE @cmd nvarchar(4000)
    
    DECLARE @dba_sql_patchlevel TABLE (
			[date]				[date] NULL,
			[productversion]	[nvarchar](128) NULL,
			[productlevel]		[nvarchar](128) NULL,
			[machinename]		[nvarchar](128) NULL,
			[instancename]		[nvarchar](128) NULL,
			[engineedition]		[nvarchar](10) NULL)
    
    --SET	@cmd = 'SELECT distinct ''' + @server_name + ''' as servername, getdate(), dba_db.dbo.f_dba_get_sqlversion() as sql_version,
		  -- dba_db.dbo.f_dba_get_sqlversion_number() as sql_version_number,
		  -- dba_db.dbo.f_dba_get_sqlversion_platform() as sql_version_platform,
		  -- @@version
		  -- from '+ @server_name + '.master.dbo.sysdatabases'
		  
	--SET @cmd = 'INSERT dbo.dba_sql_patchlevel (
	------SET @cmd = 'INSERT @dba_sql_patchlevel (
	------		date, productversion, productlevel, machinename, instancename,engineedition ) ' +
	------		'select DISTINCT getdate() as date, convert(nvarchar(128),serverproperty(''productversion'')) as sqlversion, 
	------			convert(nvarchar(128),serverproperty(''productlevel'')) as servicepack,
	------			convert(nvarchar(128),serverproperty(''machinename'')) as machinename,
	------			convert(nvarchar(128),serverproperty(''instancename'')) as instancename,
	------			CASE serverproperty(''engineedition'')
	------				when 1 THEN
	------					''Personal''
	------				when 2  THEN
	------					''standard''
	------				when 3 THEN
	------					''Enterprise''
	------				when 4 THEN
	------					''Express''
	------			end as Engineedition
	------			FROM [' + @server_name + '].master.sys.sysdatabases'

	----SET @cmd = 'INSERT @dba_sql_patchlevel (
	----		date, productversion, productlevel, machinename, instancename,engineedition ) ' +
	----		'SELECT date, sqlversion, as servicepack, machinename, instancename, Engineedition
	----			FROM [' + @server_name + '].[dba_db16].[v_dba16_sys_GetSQLServerPatchLevel]'

	SET @cmd = 'SELECT date, sqlversion, servicepack, machinename, instancename, Engineedition
				FROM [' + @server_name + '].[dba_db16].[dbo].[v_dba16_sys_GetSQLServerPatchLevel]'
				
	--SELECT @server_name, getdate(), dbo.f_dba_get_sqlversion() as sql_version,
	--	   dbo.f_dba_get_sqlversion_number() as sql_version_number,
	--	   dbo.f_dba_get_sqlversion_platform() as sql_version_platform,
	--	   @@version
	
	
	PRINT @cmd;

	INSERT @dba_sql_patchlevel (
			date, productversion, productlevel, machinename, instancename,engineedition )
	EXEC (@CMD);

	SELECT [date]
	  ,[productversion]
      ,[productlevel]
      ,[machinename]
      ,[instancename]
      ,[engineedition]
  FROM @dba_sql_patchlevel;

	
END				   






GO

GRANT EXECUTE ON [dbo].[p_dba16_stl_StealthGetSQLServerPatchLevel] TO [db_proc_exec] AS [dbo]
GO


