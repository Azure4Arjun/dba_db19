USE [model]
GO

/****** Object:  DdlTrigger [T_MOD_SP_CheckName]    Script Date: 06/18/2009 10:34:45 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO





CREATE TRIGGER [T_MOD_SP_CheckName]
ON DATABASE 
for  CREATE_PROCEDURE,ALTER_PROCEDURE
AS
BEGIN

    DECLARE @data XML;
    DECLARE @object sysname;
    SET @data = EVENTDATA();
    SET @object = @data.value('(/EVENT_INSTANCE/ObjectName)[1]', 'sysname') 
	IF (SELECT SUBSTRING (@OBJECT , 1 , 6)) Not Like
	('p[_][a-z][a-z][a-z][_]%')  --'P_'+ SUBSTRING (DB_NAME(), 1 ,3)+ '_')
		BEGIN
			RAISERROR ('Cannot create SP,Follow this format ''P_Adv_'' positions 3,4,5 must be alphabets & positions 2,6 must be underscores' ,16, 1  )
			ROLLBACK
		END
END	




GO

SET ANSI_NULLS OFF
GO

SET QUOTED_IDENTIFIER OFF
GO

DISABLE TRIGGER [T_MOD_SP_CheckName] ON DATABASE
GO

ENABLE TRIGGER [T_MOD_SP_CheckName] ON DATABASE
GO


