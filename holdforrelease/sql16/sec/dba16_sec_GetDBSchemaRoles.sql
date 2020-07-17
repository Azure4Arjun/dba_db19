SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- ======================================================================================
-- dba16_sec_GetDBSchemaRoles
--
--
-- Calls:		None
--
-- Description:	Get a listing of the roles for each schema.
-- 
-- Date			Modified By			Changes
-- 10/25/2016   Aron E. Tekulsky    Initial Coding.
-- 11/22/2017   Aron E. Tekulsky    Update to Version 140.
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

-- dba14_getdbschemaroles

-- run for each db on server

/****** Script for SelectTopNRows command from SSMS  ******/
	SELECT DISTINCT p.[name]
	    ,p.[principal_id]
	    --,p.[type]
	    ,p.[type_desc]
		  ,DB_NAME() as dbname
	    ,p.[default_schema_name]
	   ,p.[create_date]
		  ,s.name AS DBRole
		  ,p.[modify_date]
	   --,p.[owning_principal_id]
		  --,p.[sid]
		 ,p.[is_fixed_role] 
		 --,p.[authentication_type]
		 ,p.[authentication_type_desc]
		 --,p.[default_language_name]
		 --,p.[default_language_lcid]
	----------FROM [History].[sys].[database_principals] p
		 FROM [sys].[database_principals] p
			LEFT JOIN [sys].[database_role_members] r ON (r.member_principal_id= p.principal_id)
			LEFT JOIN [sys].[schemas] s ON (s.principal_id = r.role_principal_id )
	WHERE (p.principal_id = 1 OR p.principal_id > 4) AND p.principal_id < 16000
	ORDER BY p.principal_id ASC;


END
GO
