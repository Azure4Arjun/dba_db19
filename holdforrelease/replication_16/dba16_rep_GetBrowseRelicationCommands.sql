SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- ======================================================================================
-- dba16_rep_GetBrowseRelicationCommands
--
--
-- Calls:		None
--
-- Description:	Browse the replication commands.  This allows us to see the actual 
--				command string that was run for the replication item.
--
--				*** Diagnostic step 2. ***
--
--				Note: must be run against the distribution  database.
-- 
-- Date			Modified By			Changes
-- 07/20/2018   Aron E. Tekulsky    Initial Coding.
-- 03/04/2018   Aron E. Tekulsky    Update to Version 140.
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
	DECLARE @XactSeqNoStart	nchar(22)
	DECLARE @XactSeqNoEnd	nchar(22)
	
	SET @XactSeqNoStart = '0x0000002200001C78007D'; -- get this information from teh replication error details
	SET @XactSeqNoEnd	= '0x0000002200001C78007D';

-- point to the distribution database.
	USE [distribution]


-- Browse the replication commands.
	EXEC sp_browsereplcmds @xact_seqno_start = @XactSeqNoStart,
							@xact_seqno_end = @XactSeqNoEnd;

-- From the output select the command detail line that matches the comand_id listed in the replication monitor details error window.
-- In the command column right after the sp_MSins is the name of the table being operated on.

END
GO
