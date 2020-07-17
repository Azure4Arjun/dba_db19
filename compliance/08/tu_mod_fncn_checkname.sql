USE [model]
GO

/****** Object:  DdlTrigger [tu_mod_fncn_checkname]    Script Date: 06/18/2009 10:43:33 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO





CREATE TRIGGER [tu_mod_fncn_checkname]
ON DATABASE 
for CREATE_FUNCTION,ALTER_FUNCTION
AS
BEGIN

    DECLARE @data XML;
    DECLARE @object sysname;
    SET @data = EVENTDATA();
    SET @object = @data.value('(/EVENT_INSTANCE/ObjectName)[1]', 'sysname') 
	IF (SELECT SUBSTRING (@OBJECT , 1 , 6)) Not Like ('f[_][a-zA-Z][a-zA-Z][a-zA-Z][_]%') --<>(SELECT 'F_'+ SUBSTRING (DB_NAME(), 1 ,3)+'_')
		BEGIN
			RAISERROR ('Cannot create Function,Follow this format ''f_adv_'' positions 3,4,5 must be alphabets & positions 2,6 must be underscores' ,16, 1  )
			ROLLBACK
		END
END		
		




GO

SET ANSI_NULLS OFF
GO

SET QUOTED_IDENTIFIER OFF
GO

DISABLE TRIGGER [tu_mod_fncn_checkname] ON DATABASE
GO

ENABLE TRIGGER [tu_mod_fncn_checkname] ON DATABASE
GO


