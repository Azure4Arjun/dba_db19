	SELECT	
			c.session_id 
			,r.plan_handle
			,c.most_recent_sql_handle
			,CASE
				WHEN R.blocking_session_id IS NULL THEN 'Head Blocker'
				ELSE CONVERT(varchar(12),R.blocking_session_id)
				END AS blocking_session_id
			, R.start_time -- when the request arrived.
			,CASE 
				WHEN R.status IS NULL THEN 
					s.status
				ELSE R.status 
			 END AS TheStatus
			, CASE s.transaction_isolation_level
				WHEN 0 THEN 'Unspecified'
				WHEN 1 THEN 'Read Uncommitted'
				WHEN 2 THEN 'Read Committed'
				WHEN 3 THEN 'Repeatable'
				WHEN 4 THEN 'Serializable'
				WHEN 5 THEN 'Snapshot'
			END AS transaction_isolationS
			, r.last_wait_type AS last_wait_type
			, ISNULL(0,r.wait_time) AS WaitTimeMs
			, ISNULL(0,r.cpu_time) AS CPU
			, IOReads = ISNULL(0,r.logical_reads + r.reads)
			, ISNULL(0,r.writes) AS IOWrite
			, CASE
				WHEN r.open_transaction_count IS NULL THEN s.open_transaction_count 
				ELSE r.open_transaction_count
				END AS OpenTranCount
			, R.command AS CommandType
			,CASE
				WHEN R.database_id IS NULL THEN s.database_id 
				ELSE r.database_id 
				END AS TheDbid
			, CASE
				WHEN R.database_id IS NULL THEN DB_NAME(s.database_id)
				ELSE  DB_NAME(r.database_id)
				END AS database_name
			, C.connect_time
			, C.protocol_type
			,q.text AS SQLStmt	
			----------,p.query_plan 
			,S.login_name
			, S.login_time
			, s.host_name AS Host
			, c.net_transport AS Protocol
			, c.num_writes AS ConnectionWrites
			, c.num_reads AS ConnectionReads
			, c.client_net_address AS ClientAddress
			, c.auth_scheme AS Authentication
		FROM sys.dm_exec_connections C 
			LEFT OUTER JOIN sys.dm_exec_requests R on (R.session_id = c.session_id)
			JOIN sys.dm_exec_sessions s ON (c.session_id = s.session_id )
			CROSS APPLY sys.dm_exec_sql_text(c.most_recent_sql_handle ) as q			
			----------------------------CROSS APPLY sys.dm_exec_sql_text(R.sql_handle) as q
			--------------------CROSS APPLY sys.dm_exec_query_plan(R.plan_handle) p
	WHERE c.session_id > 50
		AND (s.database_id > 4 OR r.database_id > 4)
		------------------AND (r.status IN ('suspended', 'sleeping') OR s.status IN ('Sleeping '))
		AND R.blocking_session_id IS NULL



		SELECT *
			FROM sysprocesses
			Where spid >56 and spid <60




