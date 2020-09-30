SELECT SUBSTRING(dest.text, ( der.statement_start_offset / 2 ) + 1,
( CASE der.statement_end_offset
WHEN -1 THEN DATALENGTH(dest.text)
ELSE der.statement_end_offset
- der.statement_start_offset
END ) / 2 + 1) AS querystatement ,
deqp.query_plan ,
der.session_id ,
der.start_time ,
der.status ,
DB_NAME(der.database_id) AS DBName ,
USER_NAME(der.user_id) AS UserName ,
der.blocking_session_id ,
der.wait_type ,
der.wait_time ,
der.wait_resource ,
der.last_wait_type ,
der.cpu_time ,
der.total_elapsed_time ,
der.reads ,
der.writes
FROM sys.dm_exec_requests AS der
CROSS APPLY sys.dm_exec_sql_text(der.sql_handle) AS dest
CROSS APPLY sys.dm_exec_query_plan(der.plan_handle) AS deqp;