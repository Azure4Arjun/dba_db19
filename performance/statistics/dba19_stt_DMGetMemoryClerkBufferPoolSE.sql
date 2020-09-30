SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- ======================================================================================
-- dba19_stt_DMGetMemoryClerkBufferPoolSE
--
--
-- Calls:		None
--
-- Description:	Get a listing of the MEMORYCLERK_SQLBUFFERPOOL.
-- 
-- https://dba.stackexchange.com/questions/96333/how-to-resolve-resource-semaphore-and-resource-semaphore-query-compile-wait-type
-- 
-- Date			Modified By			Changes
-- 05/06/2019   Aron E. Tekulsky    Initial Coding.
-- 05/06/2019   Aron E. Tekulsky    Update to Version 140.
-- 08/13/2020   Aron E. Tekulsky    Update to Version 150.
-- ======================================================================================
--	Copyright©2001 - 2025 Aron Tekulsky.  World wide rights reserved.
--	Use of this code is free of charge but does not in any way imply transfer of 
--	Copyright ownership to the user.
--
--  This code and information are provided "AS IS" without warranty of
--  any kind, either expressed or implied, including but not limited
--  to the implied warranties of merchantability and/or fitness for a
--  particular purpose.
-- ======================================================================================
--
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;

	SELECT SUM(c.virtual_memory_committed_kb) AS sizeofbuffers
		FROM sys.dm_os_memory_clerks c
	WHERE c.type='MEMORYCLERK_SQLBUFFERPOOL';

END
GO
