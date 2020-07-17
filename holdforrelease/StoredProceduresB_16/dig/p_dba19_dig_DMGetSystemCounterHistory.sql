SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- ======================================================================================
-- p_dba19_dig_DMGetSystemCounterHistory
--
-- Arguments:	None
--				None
--
-- CallS:		None
--
-- Called BY:	None
--
-- Description:	Load all buffer manager counters into a table to be able to review 
--				history at any point in time.
--
--				Based on dba19_dig_DMGetBufferMgrStats.
-- 
--				NOTE:  requires VIEW SERVER STATE permission.
--
-- Date			Modified By			Changes
-- 07/27/2012   Aron E. Tekulsky    Initial Coding.
-- 02/01/2018   Aron E. Tekulsky    Update to V140.
-- 06/10/2020   Aron E. Tekulsky    Update to V150.
-- ======================================================================================
--	Copyright©2001 - 2025 Aron Tekulsky.  World wide rights reserved.
--	Use of this code is free of charge but does not in any way imply transfer of 
--	Copyright ownership to the user.
-- ======================================================================================
--
CREATE PROCEDURE p_dba19_dig_DMGetSystemCounterHistory 
	-- Add the parameters for the stored procedure here
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;

	DECLARE @ObjectName						nchar(128)

	DECLARE @Backgroundwriterpagessec		bigint
    DECLARE @Buffercachehitratio			bigint
    DECLARE @Buffercachehitratiobase		bigint
    DECLARE @Checkpointpagessec				bigint
    DECLARE @Databasepages					bigint
    DECLARE @Extensionallocatedpages		bigint
    DECLARE @Extensionfreepages				bigint
    DECLARE @Extensioninuseaspercentage		bigint
    DECLARE @ExtensionoutstandingIOcounter	bigint
    DECLARE @Extensionpageevictionssec		bigint
    DECLARE @Extensionpagereadssec			bigint
    DECLARE @Extensionpageunreferencedtime	bigint
    DECLARE @Extensionpagewritessec			bigint
    DECLARE @Freeliststallssec				bigint
    DECLARE @IntegralControllerSlope		bigint
    DECLARE @Lazywritessec					bigint
    DECLARE @Pagelifeexpectancy				bigint
    DECLARE @Pagelookupssec					bigint
    DECLARE @Pagereadssec					bigint
    DECLARE @Pagewritessec					bigint
    DECLARE @Readaheadpagessec				bigint
    DECLARE @Readaheadtimesec				bigint
    DECLARE @Targetpages					bigint
    DECLARE @LastModified					bigint

	DECLARE @CounterName					nvarchar(128)
	DECLARE @CntrValue						bigint

	DECLARE @dba_SystemCounterHistory TABLE (
		[ObjectName]						[nchar](128) NULL,
		[CounterName]						[nchar](128) NULL,
		[CntrValue]							[bigint] NULL)--,


	DECLARE cntr_cur CURSOR FOR 
		SELECT [ObjectName], [CounterName], [CntrValue]
				FROM @dba_SystemCounterHistory;

	------[LastModified] [datetime] NOT NULL
	-- load the counters
	INSERT INTO @dba_SystemCounterHistory (
			[ObjectName]
		  ,[CounterName]
		  ,[CntrValue])
	SELECT [object_name],[counter_name],[cntr_value]
		FROM [master].[sys].[dm_os_performance_counters]
	WHERE object_name LIKE ('%Buffer Manager%')
	ORDER BY [counter_name] ASC;


	SELECT *
		FROM @dba_SystemCounterHistory;

	-- cursor through to set local values

	OPEN cntr_cur;

	FETCH NEXT FROM cntr_cur
		INTO 
			@ObjectName, @CounterName, @CntrValue;
		
	------SET @I = 1;

	WHILE (@@FETCH_STATUS <> -1)
		BEGIN

			IF @CounterName =  'Background writer pages/sec' 
				SET @Backgroundwriterpagessec = @CntrValue

			ELSE IF @CounterName = 'Buffer cache hit ratio'
					SET @Buffercachehitratio = @CntrValue

			ELSE IF @CounterName = 'Buffer cache hit ratio base'
					SET @Buffercachehitratiobase = @CntrValue

			ELSE IF @CounterName = 'Checkpoint pages/sec'
					SET @Checkpointpagessec = @CntrValue

			ELSE IF @CounterName = 'Database pages'
					SET @Databasepages = @CntrValue

			ELSE IF @CounterName = 'Extension allocated pages'
					SET @Extensionallocatedpages = @CntrValue

			ELSE IF @CounterName = 'Extension free pages'
					SET @Extensionfreepages = @CntrValue

			ELSE IF @CounterName = 'Extension in use as percentage'
					SET @Extensioninuseaspercentage = @CntrValue

			ELSE IF @CounterName = 'Extension outstanding IO counter'
					SET @ExtensionoutstandingIOcounter = @CntrValue

			ELSE IF @CounterName = 'Extension page evictions/sec'
					SET @Extensionpageevictionssec = @CntrValue

			ELSE IF @CounterName = 'Extension page reads/sec'
					SET @Extensionpagereadssec = @CntrValue

			ELSE IF @CounterName = 'Extension page unreferenced time'
					SET @Extensionpageunreferencedtime = @CntrValue

			ELSE IF @CounterName = 'Extension page writes/sec'
					SET @Extensionpagewritessec = @CntrValue

			ELSE IF @CounterName = 'Free list stalls/sec'
					SET @Freeliststallssec = @CntrValue

			ELSE IF @CounterName = 'Integral Controller Slope'
					SET @IntegralControllerSlope = @CntrValue

			ELSE IF @CounterName = 'Lazy writes/sec'
					SET @Lazywritessec = @CntrValue

			ELSE IF @CounterName = 'Page life expectancy'
					SET @Pagelifeexpectancy = @CntrValue

			ELSE IF @CounterName = 'Page lookups/sec'
					SET @Pagelookupssec = @CntrValue

			ELSE IF @CounterName = 'Page reads/sec'
					SET @Pagereadssec = @CntrValue

			ELSE IF @CounterName = 'Page writes/sec'
					SET @Pagewritessec = @CntrValue

			ELSE IF @CounterName = 'Read ahead pages/sec'
					SET @Readaheadpagessec = @CntrValue

			ELSE IF @CounterName = 'Read ahead time/sec'
					SET @Readaheadtimesec = @CntrValue

			ELSE IF @CounterName = 'Target pages'
					SET @Targetpages = @CntrValue


			FETCH NEXT FROM cntr_cur
				INTO 
					@ObjectName, @CounterName, @CntrValue;

		END


	 --insert into the db table horizontally.
	INSERT INTO [dbo].[dba_SystemCounterHistory]
           ([ObjectName]
           ,[Backgroundwriterpagessec]
           ,[Buffercachehitratio]
           ,[Buffercachehitratiobase]
           ,[Checkpointpagessec]
           ,[Databasepages]
           ,[Extensionallocatedpages]
           ,[Extensionfreepages]
           ,[Extensioninuseaspercentage]
           ,[ExtensionoutstandingIOcounter]
           ,[Extensionpageevictionssec]
           ,[Extensionpagereadssec]
           ,[Extensionpageunreferencedtime]
           ,[Extensionpagewritessec]
           ,[Freeliststallssec]
           ,[IntegralControllerSlope]
           ,[Lazywritessec]
           ,[Pagelifeexpectancy]
           ,[Pagelookupssec]
           ,[Pagereadssec]
           ,[Pagewritessec]
           ,[Readaheadpagessec]
           ,[Readaheadtimesec]
           ,[Target pages])
		SELECT @ObjectName
			,@Backgroundwriterpagessec
			,@Buffercachehitratio			
			,@Buffercachehitratiobase		
			,@Checkpointpagessec				
			,@Databasepages					
			,@Extensionallocatedpages		
			,@Extensionfreepages				
			,@Extensioninuseaspercentage		
			,@ExtensionoutstandingIOcounter	
			,@Extensionpageevictionssec		
			,@Extensionpagereadssec			
			,@Extensionpageunreferencedtime	
			,@Extensionpagewritessec			
			,@Freeliststallssec				
			,@IntegralControllerSlope		
			,@Lazywritessec					
			,@Pagelifeexpectancy				
			,@Pagelookupssec					
			,@Pagereadssec					
			,@Pagewritessec					
			,@Readaheadpagessec				
			,@Readaheadtimesec				
			,@Targetpages;

	IF @@ERROR <> 0 GOTO ErrorHandler

	RETURN 1

	ErrorHandler:
	RETURN -1 
END
GO
GRANT EXECUTE ON p_dba19_dig_DMGetSystemCounterHistory TO [db_proc_exec] AS [dbo]
GO
