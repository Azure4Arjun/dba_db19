SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- ======================================================================================
-- p_dba19_dig_DMGetBlocksAndSqlExecuting
--
-- Arguments:	@TheSQLStatement	nvarchar(4000) OUTPUT
--				None
--
-- CallS:		None
--
-- Called BY:	p_dba19_alt_GetAlertResponse
--
-- Description:	
-- 
-- Date			Modified By			Changes
-- 11/11/2016   Aron E. Tekulsky    Initial Coding.
-- 02/18/2018   Aron E. Tekulsky    Update to Version 140.
-- 05/26/2020   Aron E. Tekulsky    Update to Version 150.
-- ======================================================================================
--	Copyright©2001 - 2025 Aron Tekulsky.  World wide rights reserved.
--	Use of this code is free of charge but does not in any way imply transfer of 
--	Copyright ownership to the user.
-- ======================================================================================
--
CREATE PROCEDURE p_dba19_dig_DMGetBlocksAndSqlExecuting 
	-- Add the parameters for the stored procedure here
	@TheSQLStatement	nvarchar(4000) OUTPUT
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;

	--DECLARE @StartDateTime	Datetime
	DECLARE @Authentication			nvarchar(40)
	DECLARE @BlkBy					smallint
	DECLARE @ConnectionWrites		int
	DECLARE @ConnectionReads		int
	DECLARE @ClientAddress			varchar(48)
	DECLARE @CommandType			nvarchar(32)
	DECLARE @CPU					int
	DECLARE @DBName					nvarchar(128)
	DECLARE @Executions		        int
	DECLARE @ElapsedMS				int
	DECLARE @Host					nvarchar(128)
	DECLARE @IOReads				bigint
	DECLARE @IOWrites				bigint
	DECLARE @LastWaitType			nvarchar(60)
	DECLARE @Login					nvarchar(128)
	DECLARE @ObjectName				nvarchar(1000)
	DECLARE @Protocol				nvarchar(40)
	DECLARE @SQLStatement			nvarchar(4000)
	DECLARE @StartDate				varchar(8)
	DECLARE @StartTime				varchar(6)
	DECLARE @SPID					smallint
	DECLARE @STATUS					nvarchar(30)
	DECLARE @StartDateTime			datetime
	DECLARE @transaction_isolation varchar(16)



	SELECT
			@SPID                = er.session_id
			,@BlkBy              = er.blocking_session_id      
			,@ElapsedMS          = er.total_elapsed_time
			,@CPU                = er.cpu_time
			,@IOReads            = er.logical_reads + er.reads
			,@IOWrites           = er.writes    
			,@Executions         = ec.execution_count  
			,@CommandType        = er.command        
			,@ObjectName         = OBJECT_SCHEMA_NAME(qt.objectid,dbid) + '.' + OBJECT_NAME(qt.objectid, qt.dbid)  
			,@SQLStatement       =
			REPLACE(qt.text,char(9),' ') -- <tab>
			--REPLACE(SUBSTRING
			--	(
			-- qt.text, 1,4000),'	',' ')
			 ----------qt.text, er.statement_start_offset/2, (CASE WHEN er.statement_end_offset = -1 THEN LEN(CONVERT(nvarchar(MAX), qt.text)) * 2
				----------											ELSE er.statement_end_offset
				----------										END - er.statement_start_offset)/2
				----------)        
			,@STATUS             = ses.STATUS
			,@Login				 = ses.login_name
			,@Host               = ses.host_name
			,@DBName             = DB_Name(er.database_id)
			,@LastWaitType       = er.last_wait_type
			,@StartDateTime      = er.start_time
			,@Protocol           = con.net_transport
			,@transaction_isolation =
			 CASE ses.transaction_isolation_level
				    WHEN 0 THEN 'Unspecified'
					WHEN 1 THEN 'Read Uncommitted'
		            WHEN 2 THEN 'Read Committed'
			        WHEN 3 THEN 'Repeatable'
				    WHEN 4 THEN 'Serializable'
					WHEN 5 THEN 'Snapshot'
			 END
			,@ConnectionWrites   = con.num_writes
			,@ConnectionReads    = con.num_reads
			,@ClientAddress      = con.client_net_address
			,@Authentication     = con.auth_scheme
		FROM sys.dm_exec_requests er
			LEFT JOIN sys.dm_exec_sessions ses    ON ses.session_id = er.session_id
			LEFT JOIN sys.dm_exec_connections con ON con.session_id = ses.session_id
			CROSS APPLY sys.dm_exec_sql_text(er.sql_handle) AS qt
			OUTER APPLY
				(
					SELECT execution_count = MAX(cp.usecounts)
						FROM sys.dm_exec_cached_plans cp
					 WHERE cp.plan_handle = er.plan_handle
				) ec
	WHERE er.blocking_session_id <> 0
	ORDER BY er.blocking_session_id DESC, er.logical_reads + er.reads DESC, er.session_id  

	IF @@ERROR <> 0 GOTO ErrorHandler

	-- remove embedded control characters
	SET @SQLStatement = REPLACE(@SQLStatement,CHAR(10),' '); -- <lf>
	SET @SQLStatement = REPLACE(@SQLStatement,CHAR(13),' '); -- <cr>

	-- update the results top the audit table
	-- EXEC p_dba14_SetBlockingQueriesTable
	INSERT INTO [BlockingQueries]
           ([StartDate]
           ,[StartTime]
           ,[SPID]
           ,[BlkBy]
           ,[ElapsedMS]
           ,[CPU]
           ,[IOReads]
           ,[IOWrites]
           ,[Executions]
           ,[CommandType]
           ,[ObjectName]
           ,[SQLStatement]
           ,[SessionSTATUS]
           ,[SessionLogin]
           ,[Host]
           ,[DBName]
           ,[LastWaitType]
           ,[StartDateTime]
           ,[Protocol]
           ,[transaction_isolation]
           ,[ConnectionWrites]
           ,[ConnectionReads]
           ,[ClientAddress]
           ,[ConsAuthentication])
	     VALUES (
		 @StartDate
		,@StartTime
		,@SPID
		,@BlkBy
		,@ElapsedMS
		,@CPU
		,@IOReads
		,@IOWrites
		,@Executions
		,@CommandType
		,@ObjectName
		,@SQLStatement
		,@STATUS
		,@Login
		,@Host
		,@DBName
		,@LastWaitType
		,@StartDateTime
		,@Protocol
		,@transaction_isolation
		,@ConnectionWrites
		,@ConnectionReads
		,@ClientAddress
		,@Authentication	
		 )

	-- set the return value
	SET @TheSQLStatement = @SQLStatement;


	IF @@ERROR <> 0 GOTO ErrorHandler

	RETURN 1

	ErrorHandler:
	RETURN -1 
END
GO
GRANT EXECUTE ON p_dba19_dig_DMGetBlocksAndSqlExecuting TO [db_proc_exec] AS [dbo]
GO
