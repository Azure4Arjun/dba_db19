USE [model]
GO

SET ANSI_NULLS ON 
GO
SET QUOTED_IDENTIFIER ON 
GO

CREATE TRIGGER [tu_mod_db_proc_exec] 
ON DATABASE for CREATE_PROCEDURE, ALTER_PROCEDURE, CREATE_FUNCTION, ALTER_FUNCTION
AS
BEGIN
DECLARE @data XML; 
DECLARE @name varchar(20) 
SET @name = 'db_proc_exec' 
SET @data = EVENTDATA(); 
Create table #temp(sql_cmd nvarchar(4000)) 
Insert #temp(sql_cmd) values(@data.value('(/EVENT_INSTANCE/TSQLCommand)[1]', 'nvarchar(4000)') ) 
--select charindex('db_proc_exec',sql_cmd) b from #temp
IF (select charindex('db_proc_exec',sql_cmd) b from #temp) =0 
 Begin
   Raiserror ( 'Please include grant Execute permission to db_proc_exec role at End', 16,1) 
   Rollback
 END

END
GO
SET ANSI_NULLS OFF 
GO
SET QUOTED_IDENTIFIER OFF 