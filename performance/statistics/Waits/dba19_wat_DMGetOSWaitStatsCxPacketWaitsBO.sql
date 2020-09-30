SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- ======================================================================================
-- dba19_wat_DMGetOSWaitStatsCxPacketWaitsBO
--
--
-- Calls:		None
--
-- Description:	Get a list of CXPACKET Waits.
--
-- https://www.brentozar.com/archive/2013/08/what-is-the-cxpacket-wait-type-and-how-do-you-reduce-it/
--
--				CXPACKET Waits are caused by multi threaded queries.
--				Some of the threads have completed their work and are waiting
--				for the rest to catch up. It can be reduced or eliminated by
--				adjusting MAXDOP to a higher number. It may also require an
--				increae in the number of processors on the box.
 --				you may also need to change the cost threshold for parallelism (default is 5).  
 --				In today's world a starting nalue of 50 is reasonable and will reduce the number of CXPACKET WAITS.
-- 
-- Date			Modified By			Changes
-- 01/11/2019   Aron E. Tekulsky    Initial Coding.
-- 01/11/2019   Aron E. Tekulsky    Update to Version 140.
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

	SELECT s.wait_type , s.waiting_tasks_count , s.wait_time_ms ,  s.max_wait_time_ms , s.signal_wait_time_ms 
		FROM sys.dm_os_wait_stats s
	WHERE s.wait_type IN ('CXPACKET')
	ORDER BY s.wait_type ;

END
GO
