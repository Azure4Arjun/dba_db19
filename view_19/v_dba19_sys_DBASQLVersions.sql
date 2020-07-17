USE [dba_db19]
GO

/****** Object:  View [dbo].[v_dba19_sys_DBASQLVersions]    Script Date: 5/29/2020 11:10:01 AM ******/
DROP VIEW [dbo].[v_dba19_sys_DBASQLVersions]
GO

/****** Object:  View [dbo].[v_dba19_sys_DBASQLVersions]    Script Date: 5/29/2020 11:10:01 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


-- ======================================================================================
-- v_dba19_DBASQLVersions
--
--
-- Description:	
-- 
-- Date			Modified By			Changes
-- 05/20/2020   Aron E. Tekulsky    Initial Coding.
-- 05/20/2020   Aron E. Tekulsky    Update to Version 150.
-- ======================================================================================
--	Copyright©2001 - 2025 Aron Tekulsky.  World wide rights reserved.
--	Use of this code is free of charge but does not in any way imply transfer of 
--	Copyright ownership to the user.
-- ======================================================================================

CREATE VIEW [dbo].[v_dba19_sys_DBASQLVersions] AS
SELECT [VersionName]
      ,[CompatibilityLevel]
  FROM [dba_db19].[dbo].[dba_SQL_Versions]
  GROUP BY [VersionName],[CompatibilityLevel]
GO


