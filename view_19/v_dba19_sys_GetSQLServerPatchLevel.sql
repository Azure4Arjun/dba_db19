USE dba_db19
GO

IF object_id(N'dbo.v_dba19_sys_GetSQLServerPatchLevel', 'V') IS NOT NULL
	DROP VIEW dbo.v_dba19_sys_GetSQLServerPatchLevel
GO

-- ======================================================================================
-- v_dba19_sys_GetSQLServerPatchLevel
--
--
-- Description:	check the current level of SQL Server.
-- 
-- Date			Modified By			Changes
-- 12/02/2009   Aron E. Tekulsky    Initial Coding.
-- 04/19/2012	Aron E. Tekulsky	Update to v100.
-- 07/27/2019	Aron E. Tekulsky	Update to v140.
-- 05/19/2020	Aron E. Tekulsky	Update to v150.
-- ======================================================================================
--	Copyright©2001 - 2025 Aron Tekulsky.  World wide rights reserved.
--	Use of this code is free of charge but does not in any way imply transfer of 
--	Copyright ownership to the user.
-- ======================================================================================

CREATE VIEW dbo.v_dba19_sys_GetSQLServerPatchLevel AS
			SELECT DISTINCT getdate() AS date, CONVERT(nvarchar(128),serverproperty('productversion')) AS sqlversion, 
				CONVERT(nvarchar(128),serverproperty('productlevel')) AS servicepack,
				CONVERT(nvarchar(128),serverproperty('machinename')) AS machinename,
				CONVERT(nvarchar(128),serverproperty('instancename')) AS instancename,
				CASE serverproperty('engineedition')
					WHEN 1 THEN
						'Personal'
					WHEN 2  THEN
						'Standard'
					WHEN 3 THEN
						'Enterprise'
					WHEN 4 THEN
						'Express'
				END AS Engineedition
				FROM master.sys.sysdatabases;
