SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- ======================================================================================
-- dba19_ssi_GetDerivedMessageTables
--
--
-- Calls:		None
--
-- Description:	
-- 
-- https://docs.microsoft.com/en-us/sql/integration-services/system-views/catalog-operation-messages-ssisdb-database?redirectedfrom=MSDN&view=sql-server-ver15
--
-- https://dba.stackexchange.com/questions/118737/how-to-query-ssisdb-to-find-out-the-errors-in-the-packages
--
-- Date			Modified By			Changes
-- 01/14/2020   Aron E. Tekulsky    Initial Coding.
-- 01/14/2020   Aron E. Tekulsky    Update to Version 150.
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

	--This query translates the message_type from SSISDB.catalog.operation_messages
	-- into useful text.

	SELECT d.message_type, d.message_desc
		FROM (VALUES
			(-1,	'Unknown')
		,	(120,	'Error')
		,	(110,	'Warning')
		,	(10,	'Pre-validate')
		,	(20,	'Post-validate')
		,	(30,	'Pre-execute')
		,	(40,	'Post-execute')
		,	(50,	'StatusChange')
		,	(60,	'Progress')
		,	(70,	'Information')
		,	(80,	'VariableValueChanged')
		,	(90,	'Diagnostic')
		,	(100,	'QueryCancel')
		,	(130,	'TaskFailed')
		,	(200,	'Custom')
		,	(140,	'DiagnosticEx Whenever an Execute Package task executes a child package, it logs this event. The event message consists of the parameter values passed to child packages. The value of the message column for DiagnosticEx is XML text.')
		,	(400,	'NonDiagnostic')
		) d (message_type, message_desc);

-- where was the error message generated?
	SELECT d.message_source_type
			,d.message_source_desc
		FROM
		( VALUES
			(10,	'Entry APIs, such as T-SQL and CLR Stored procedures')
		,	(20,	'External process used to run package (ISServerExec.exe)')
		,	(30,	'Package-level objects')
		,	(40,	'Control Flow tasks')
		,	(50,	'Control Flow containers')
		,	(60,	'Data Flow task')
		) a (message_source_type, message_source_desc);

END
GO
