
/****** Object:  DdlTrigger [tu_mod_tbl_checkname]    Script Date: 06/18/2009 10:44:13 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO





CREATE TRIGGER [tu_mod_tbl_checkname]
ON DATABASE 
for CREATE_TABLE,ALTER_TABLE
AS
BEGIN

    DECLARE @data XML;
    DECLARE @object sysname;
    SET @data = EVENTDATA();
    SET @object = @data.value('(/EVENT_INSTANCE/ObjectName)[1]', 'sysname') 
	IF (SELECT SUBSTRING (@OBJECT , 1 , 4)) Not Like
	('[a-z][a-z][a-z][_]%')
 --!= (SELECT  SUBSTRING (DB_NAME(), 1 ,3)+'_')
		BEGIN
			RAISERROR ('Cannot create Table,Follow this format ''adv_'' positions 1,2,3 must be alphabets & position 4 must be an underscore' ,16, 1  )
			ROLLBACK
		END
END		
		




GO

SET ANSI_NULLS OFF
GO

SET QUOTED_IDENTIFIER OFF
GO

DISABLE TRIGGER [tu_mod_tbl_checkname] ON DATABASE
GO

ENABLE TRIGGER [tu_mod_tbl_checkname] ON DATABASE
GO


