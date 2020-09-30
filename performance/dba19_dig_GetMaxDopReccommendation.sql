SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- ======================================================================================
-- dba19_dig_GetMaxDopReccommendation
--
--
-- Calls:		None
--
-- Description:	Get a calculated recommendation for a max dop setting.
-- 
-- Date			Modified By			Changes
-- 08/31/2016   Aron E. Tekulsky    Initial Coding.
-- 01/20/2018   Aron E. Tekulsky    Update to Version 140.
-- 08/11/2020   Aron E. Tekulsky    Update to Version 150.
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

/* 
	This will recommend a MAXDOP setting appropriate for your machine's NUMA memory
	configuration.  You will need to evaluate this setting in a non-production 
	environment before moving it to production.

	MAXDOP can be configured using:  
	EXEC sp_configure 'max degree of parallelism',X;
	RECONFIGURE

	If this instance is hosting a Sharepoint database, you MUST specify MAXDOP=1 
	(URL wrapped for readability)
	http://blogs.msdn.com/b/rcormier/archive/2012/10/25/
	you-shall-configure-your-maxdop-when-using-sharepoint-2013.aspx

	Biztalk (all versions, including 2010): 
	MAXDOP = 1 is only required on the BizTalk Message Box
	database server(s), and must not be changed; all other servers hosting other 
	BizTalk Server databases may return this value to 0 if set.
	http://support.microsoft.com/kb/899000
*/


	DECLARE @CoreCount int;
	DECLARE @NumaNodes int;

	SET @CoreCount = (SELECT i.cpu_count from sys.dm_os_sys_info i);
	SET @NumaNodes = (
		 SELECT MAX(c.memory_node_id) + 1 
			FROM sys.dm_os_memory_clerks c 
		 WHERE memory_node_id < 64
    );

	IF @CoreCount > 4 /* If less than 5 cores, don't bother. */
		BEGIN
			DECLARE @MaxDOP int;

    /* 3/4 of Total Cores in Machine */
			SET @MaxDOP = @CoreCount * 0.75; 

    /* if @MaxDOP is greater than the per NUMA node
       Core Count, set @MaxDOP = per NUMA node core count
    */
			IF @MaxDOP > (@CoreCount / @NumaNodes) 
				SET @MaxDOP = (@CoreCount / @NumaNodes) * 0.75;

    /*
        Reduce @MaxDOP to an even number 
    */
			SET @MaxDOP = @MaxDOP - (@MaxDOP % 2);

    /* Cap MAXDOP at 8, according to Microsoft */
			IF @MaxDOP > 8 SET @MaxDOP = 8;

			PRINT 'Suggested MAXDOP = ' + CAST(@MaxDOP as varchar(max));
		END
	ELSE
		BEGIN
			PRINT 'Suggested MAXDOP = 0 since you have less than 4 cores total.';
			PRINT 'This is the default setting, you likely do not need to do';
			PRINT 'anything.';
		END
END
GO
