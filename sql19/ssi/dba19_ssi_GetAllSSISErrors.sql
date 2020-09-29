SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- ======================================================================================
-- dba19_ssi_GetAllSSISErrors
--
--
-- Calls:		None
--
-- Description:	
--
-- https://dba.stackexchange.com/questions/118737/how-to-query-ssisdb-to-find-out-the-errors-in-the-packages
-- 
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

	-- http://msdn.microsoft.com/en-us/library/ff877994.aspx
	-- Find all error messages
	SELECT
		OM.operation_message_id
	,   OM.operation_id
	,   OM.message_time
	,   OM.message_type
	,   OM.message_source_type
	,   OM.message
	,   OM.extended_info_id
		FROM
			catalog.operation_messages AS OM
	WHERE
		OM.message_type = 120;

	-- Generate all the messages associated to failing operations
	SELECT
			OM.operation_message_id
		,   OM.operation_id
		,   OM.message_time
		,   OM.message_type
		,   OM.message_source_type
		,   OM.message
		,   OM.extended_info_id
		FROM
			catalog.operation_messages AS OM
			INNER JOIN
			(  
				-- Find failing operations
				SELECT DISTINCT
					OM.operation_id  
				FROM
					catalog.operation_messages AS OM
				WHERE
					OM.message_type = 120
			) D
			ON D.operation_id = OM.operation_id;

	-- Find all messages associated to the last failing run
	SELECT
			OM.operation_message_id
		,   OM.operation_id
		,   OM.message_time
		,   OM.message_type
		,   OM.message_source_type
		,   OM.message
		,   OM.extended_info_id
		FROM
			catalog.operation_messages AS OM
	WHERE
		OM.operation_id = 
		(  
			-- Find the last failing operation
			-- lazy assumption that biggest operation
			-- id is last. Could be incorrect if a long
			-- running process fails after a quick process
			-- has also failed
			SELECT 
				MAX(OM.operation_id)
				FROM
					catalog.operation_messages AS OM
			WHERE
				OM.message_type = 120
		);
END
GO
