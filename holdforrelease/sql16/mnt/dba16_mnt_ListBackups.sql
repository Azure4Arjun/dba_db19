SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- ======================================================================================
-- dba16_mnt_ListBackups
--
--
-- Calls:		None
--
-- Description:	Get a listing of each type of backup fo reach database.
-- 
-- Date			Modified By			Changes
-- 06/10/2013   Aron E. Tekulsky    Initial Coding.
-- 11/07/2017   Aron E. Tekulsky    Update to Version 140.
-- ======================================================================================
--	Copyright©2001 - 2025 Aron Tekulsky.  World wide rights reserved.
--	Use of this code is free of charge but does not in any way imply transfer of 
--	Copyright ownership to the user.
-- ======================================================================================
--
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here

	SELECT 
		server_name
		,machine_name
		,database_name
	    ,name
		,backup_start_date
		,backup_finish_date
		,CASE TYPE
			WHEN 'D' THEN 'Database'
			WHEN 'I' THEn 'Differential database'
			WHEN 'L' THEN 'Log'
			WHEN 'F' THEN 'File or filegroup'
			WHEN 'G' THEN 'Differential file'
			WHEN 'P' THEN 'Partial'
			WHEN 'Q' THEN 'Differential partial'
			ELSE ''
			END AS Type
	    ,convert(numeric(10,1),backup_size/1048576) AS backup_size_GB
		,convert(varchar(10),software_major_version) + '.' + convert(varchar(10),software_minor_version) + '.' + convert(varchar(10),software_build_version) as software_version
		,database_creation_date
		,recovery_model
		,expiration_date
		,CASE compatibility_level 
			WHEN  80 THEN 'SQL Server 2000'
			WHEN  90 THEN 'SQL Server 2005'
			WHEN 100 THEN 'SQL Server 2008'
			WHEN 110 THEN 'SQL Server 2012'
			END as Compatability_level
		FROM msdb.dbo.backupset
	WHERE type =  'D' 
	ORDER BY database_name asc, backup_start_date DESC;

END
GO
