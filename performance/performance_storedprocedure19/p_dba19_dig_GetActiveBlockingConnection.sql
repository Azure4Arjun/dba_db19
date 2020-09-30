SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- ======================================================================================
-- p_dba19_dig_GetActiveBlockingConnection
--
-- Arguments:	None
--				None
--
-- CallS:		None
--
-- Called BY:	None
--
-- Description:	Find and display a list of the actively blocking or blocked spids.
-- 
-- Date			Modified By			Changes
-- 06/24/2013   Aron E. Tekulsky    Initial Coding.
-- 02/13/2018   Aron E. Tekulsky    Update to Version 140.
-- 08/12/2020   Aron E. Tekulsky    Update to Version 150.
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
CREATE PROCEDURE p_dba19_dig_GetActiveBlockingConnection 
	-- Add the parameters for the stored procedure here
	----None int = 0, 
	----None int = 0
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;

	/*Purpose:
		Identify active or blocking connections, and list the active command on the connection. */

	/*
		Status Definitions, per Books Online:

		Background	SPID is performing a background task.
		Sleeping	SPID is not currently executing. This usually indicates that the
					SPID is awaiting a command from the application.
		Runnable	SPID is currently executing.
		Dormant  	Same as Sleeping, except Dormant also indicates that the SPID has
					been reset after completing an RPC event. The reset cleans up resources used during the RPC event. This is a normal state and the SPID is available and waiting to execute further commands.
		Rollback	The SPID is in rollback of a transaction.
		Defwakeup	Indicates that a SPID is waiting on a resource that is in the
					process of being freed. The waitresource field should indicate the resource in question.
		Spinloop	Process is waiting while attempting to acquire a spinlock used for
					concurrency control on SMP systems

	*/

	DECLARE @cmd	varchar(7000)
	DECLARE @spid	int

	CREATE TABLE #ProcCheck(
		Status		varchar(50) ,
		SPID		int ,
		CPU			int ,
		Pys_IO		int ,
		WaitTime	int ,
		BlockSPID	int ,
		LastCmd		varchar(500) ,
		HostName	varchar(36) ,
		ProgName	varchar(100) ,
		NTUser		varchar(50) ,
		LoginTime	datetime ,
		LastBatch	datetime ,
		OpenTrans	int)

	CREATE TABLE #ProcInfo(
		EventType	varchar(100) ,
		Parameters	int ,
		EventInfo	varchar(7000))

	INSERT INTO #ProcCheck
			(Status, SPID, CPU, Pys_IO, WaitTime, BlockSPID, HostName, ProgName, NTUSer, LoginTime, LastBatch, OpenTrans)
	SELECT status, SPID, CPU, Physical_IO, WaitTime, Blocked, SUBSTRING(HostName, 1, 36), 
			SUBSTRING(Program_Name, 1, 100), SUBSTRING(nt_username, 1, 50), Login_Time, Last_Batch, Open_Tran 
		FROM master..sysprocesses (NOLOCK)
	WHERE (blocked > 0 
			OR spid in (SELECT blocked 
							FROM master..sysprocesses (NOLOCK) 
						WHERE blocked > 0)
			OR open_tran > 0)
			AND SPID <> @@SPID;


		--SELECT * aet code to test
		--	FROM #ProcCheck

		-- Declare the cursor
	DECLARE Procs CURSOR fast_forward FOR
		SELECT SPID FROM #ProcCheck;

		-- open the cursor
	OPEN Procs;

	-- fetch the first row
	FETCH NEXT FROM Procs 
		INTO @SPID;

	WHILE (@@FETCH_STATUS = 0)
		BEGIN

			SET @cmd = 'DBCC INPUTBUFFER(' + CONVERT(varchar, @SPID) + ')';

			INSERT INTO #ProcInfo
				EXEC(@cmd);

			SELECT @cmd = EventInfo
				FROM #ProcInfo;

			DELETE 
				FROM #ProcInfo;

			UPDATE #ProcCheck
				SET LastCmd = SUBSTRING(@cmd, 1, 500)
			WHERE SPID = @SPID;

			FETCH NEXT FROM Procs 
				INTO @SPID;

		END

		-- close the cursor
	CLOSE Procs;

	-- deallocate the cursor
	DEALLOCATE Procs;

	SELECT * 
		FROM #ProcCheck;

		-- drop tremp tables
	DROP TABLE #ProcCheck;
	DROP TABLE #ProcInfo;


	IF @@ERROR <> 0 GOTO ErrorHandler

	RETURN 1

	ErrorHandler:
	RETURN -1 
END
GO
----GRANT EXECUTE ON p_dba19_dig_GetActiveBlockingConnection TO [db_proc_exec] AS [dbo]
----GO
