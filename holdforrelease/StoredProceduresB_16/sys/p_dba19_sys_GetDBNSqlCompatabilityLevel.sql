SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- ======================================================================================
-- p_dba19_sys_GetDBNSqlCompatabilityLevel
--
-- Arguments:	None
--				None
--
-- CallS:		None
--
-- Called BY:	None
--
-- Description:	Compare the compatability level of each db to the sql level and report mismatches.
-- 
-- Date			Modified By			Changes
-- 01/09/2013   Aron E. Tekulsky    Initial Coding.
-- 02/11/2018   Aron E. Tekulsky    Update to Version 140.
-- 05/26/2020   Aron E. Tekulsky    Update to Version 150.
-- ======================================================================================
--	Copyright©2001 - 2025 Aron Tekulsky.  World wide rights reserved.
--	Use of this code is free of charge but does not in any way imply transfer of 
--	Copyright ownership to the user.
-- ======================================================================================
--
CREATE PROCEDURE p_dba19_sys_GetDBNSqlCompatabilityLevel 
	-- Add the parameters for the stored procedure here
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;

	DECLARE @productversion		nvarchar(128)
	DECLARE @productmajor		int
	DECLARE @productminor		int
	DECLARE @productmajornminor	decimal(5,2)
	DECLARE @compatabilitylevel	tinyint


	-- get the basic product version
	SET @productversion = convert(nvarchar(128),SERVERPROPERTY('productversion'));--, SERVERPROPERTY ('productlevel'), SERVERPROPERTY ('edition')
	SET @productmajor = substring(@productversion, 1,charindex('.',@productversion)-1);
	SET @productminor = substring(@productversion, charindex('.',@productversion)+1,charindex('.',@productversion,charindex('.',@productversion))-1);
	SET @productmajornminor = convert(decimal(5,2),substring(convert(nvarchar(128),SERVERPROPERTY('productversion')),1,5));

	print @productversion;
	PRINT @productmajor;
	print @productminor;
	print @productmajornminor;

			SET @compatabilitylevel = 
				CASE @productmajornminor
					WHEN 8.0 THEN 80
					WHEN 9.0 THEN 90
					WHEN 10.5 THEN 100
					WHEN 11.0 THEN 110
			END ;

	-- now we need to get 
	SELECT @@servername as servername, d.name as dbname, d.database_id, d.create_date, @compatabilitylevel as servercompatabilitylevel, d.compatibility_level, d.user_access_desc, d.state_desc
		FROM sys.databases d
	WHERE d.compatibility_level <> @compatabilitylevel;


	IF @@ERROR <> 0 GOTO ErrorHandler;

	RETURN 1

	ErrorHandler:
	RETURN -1 
END
GO
GRANT EXECUTE ON p_dba19_sys_GetDBNSqlCompatabilityLevel TO [db_proc_exec] AS [dbo]
GO
