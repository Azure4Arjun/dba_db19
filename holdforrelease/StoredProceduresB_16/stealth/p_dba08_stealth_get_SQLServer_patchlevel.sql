USE [dba_db08]
GO
/****** Object:  StoredProcedure [dbo].[p_dba08_stealth_get_SQLServer_patchlevel]    Script Date: 03/05/2013 12:40:33 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


-- ==============================================================================
-- p_dba08_stealth_get_SQLServer_patchlevel
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
-- ===============================================================================
--	Copyright©2009 - 2012 Aron Tekulsky.  World wide rights reserved.
--	Use of this code is free of charge but does not in any way imply transfer of 
--	Copyright ownership to the user.
-- ===============================================================================

ALTER PROCEDURE [dbo].[p_dba08_stealth_get_SQLServer_patchlevel] 
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
	SET @cmd = 'INSERT @dba_sql_patchlevel (
			date, productversion, productlevel, machinename, instancename,engineedition ) ' +
			'select DISTINCT getdate() as date, convert(nvarchar(128),serverproperty(''productversion'')) as sqlversion, 
				convert(nvarchar(128),serverproperty(''productlevel'')) as servicepack,
				convert(nvarchar(128),serverproperty(''machinename'')) as machinename,
				convert(nvarchar(128),serverproperty(''instancename'')) as instancename,
				CASE serverproperty(''engineedition'')
					when 1 THEN
						''Personal''
					when 2  THEN
						''standard''
					when 3 THEN
						''Enterprise''
					when 4 THEN
						''Express''
				end as Engineedition
				FROM [' + @server_name + '].master.sys.sysdatabases'
				
	--SELECT @server_name, getdate(), dbo.f_dba_get_sqlversion() as sql_version,
	--	   dbo.f_dba_get_sqlversion_number() as sql_version_number,
	--	   dbo.f_dba_get_sqlversion_platform() as sql_version_platform,
	--	   @@version
	
	
	 print @cmd
	
	EXEC (@CMD)

	SELECT [date]
	  ,[productversion]
      ,[productlevel]
      ,[machinename]
      ,[instancename]
      ,[engineedition]
  FROM [dba_db08].[dbo].[dba_sql_patchlevel]

	
END				   






GO
GRANT EXECUTE ON [dbo].[p_dba08_stealth_get_SQLServer_patchlevel] TO [db_proc_exec] AS [dbo]