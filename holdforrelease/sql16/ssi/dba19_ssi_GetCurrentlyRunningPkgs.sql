SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- ======================================================================================
-- dba19_ssi_GetCurrentlyRunningPkgs
--
--
-- Calls:		None
--
-- Description:	Query currently running packages.
-- 
-- https://dba.stackexchange.com/questions/118737/how-to-query-ssisdb-to-find-out-the-errors-in-the-packages
--
-- Must point to SSISDB to run.
-- Date			Modified By			Changes
-- 01/06/2020   Aron E. Tekulsky    Initial Coding.
-- 01/06/2020   Aron E. Tekulsky    Update to Version 150.
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
	SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;

	SELECT E.execution_id, 
		   E.folder_name, 
		   E.project_name, 
		   E.package_name, 
		   E.reference_id, 
		   E.reference_type, 
		   E.environment_folder_name, 
		   E.environment_name, 
		   E.project_lsn, 
		   E.executed_as_sid, 
		   E.executed_as_name, 
		   E.use32bitruntime, 
		   E.operation_type, 
		   E.created_time, 
		   E.object_type, 
		   E.object_id, 
		   E.STATUS, 
		   E.start_time, 
		   E.end_time, 
		   E.caller_sid, 
		   E.caller_name, 
		   E.process_id, 
		   E.stopped_by_sid, 
		   E.stopped_by_name, 
		   E.dump_id, 
		   E.server_name, 
		   E.machine_name, 
		   E.total_physical_memory_kb, 
		   E.available_physical_memory_kb, 
		   E.total_page_file_kb, 
		   E.available_page_file_kb, 
		   E.cpu_count, 
		   F.folder_id, 
		   F.name, 
		   F.description, 
		   F.created_by_sid, 
		   F.created_by_name, 
		   F.created_time, 
		   P.project_id, 
		   P.folder_id, 
		   P.name, 
		   P.description, 
		   P.project_format_version, 
		   P.deployed_by_sid, 
		   P.deployed_by_name, 
		   P.last_deployed_time, 
		   P.created_time, 
		   P.object_version_lsn, 
		   P.validation_status, 
		   P.last_validation_time, 
		   PKG.package_id, 
		   PKG.name, 
		   PKG.package_guid, 
		   PKG.description, 
		   PKG.package_format_version, 
		   PKG.version_major, 
		   PKG.version_minor, 
		   PKG.version_build, 
		   PKG.version_comments, 
		   PKG.version_guid, 
		   PKG.project_id, 
		   PKG.entry_point, 
		   PKG.validation_status, 
		   PKG.last_validation_time
		FROM SSISDB.catalog.executions AS E
			INNER JOIN ssisdb.catalog.folders AS F ON (F.name = E.folder_name)
			INNER JOIN SSISDB.catalog.projects AS P ON (P.folder_id = F.folder_id)
													AND (P.name = E.project_name)
			INNER JOIN SSISDB.catalog.packages AS PKG ON (PKG.project_id = P.project_id)
													  AND (PKG.name = E.package_name)
			INNER JOIN [catalog].[operation_messages] m ON (m.operation_id = e.execution_id )
	WHERE m.message_type = 120
	ORDER BY e.folder_name ASC, e.project_name ASC, e.package_name ASC;

END
GO
