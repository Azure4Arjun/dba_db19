
/****** Object:  DdlTrigger [tu_mod_trgr_checkname]    Script Date: 06/18/2009 13:50:34 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO





CREATE TRIGGER [tu_mod_trgr_checkname]
ON DATABASE 
for CREATE_TRIGGER,ALTER_TRIGGER
AS
BEGIN

    DECLARE @data XML;
    DECLARE @object sysname;
    SET @data = EVENTDATA();
    SET @object = @data.value('(/EVENT_INSTANCE/ObjectName)[1]', 'sysname') 
	 IF (SELECT SUBSTRING (@OBJECT , 1 , 7)) Not Like
	  ('t[iud][_][a-z][a-z][a-z][_]%') --!= (SELECT 'T_'+ SUBSTRING (DB_NAME(), 1 ,3) + '_')
		BEGIN
			RAISERROR ('Cannot create Trigger,Follow this format ''tu_Adv_'' positions 4,5,6 must be alphabets & positions 3,7 must be underscores' ,16, 1  )
			ROLLBACK
		END	
/*ELSE 
	 IF (SELECT SUBSTRING (@OBJECT , 1 , 6)) != (SELECT 'TU_'+ SUBSTRING (DB_NAME(), 1 ,3))
		BEGIN
			RAISERROR ('Cannot create Trigger, Name of Trigger should start with TU_ followed by first three letters of database name, Eg:TU_Adv for Adventure database' ,16, 1  )
			ROLLBACK
		END	
ELSE 
	 IF (SELECT SUBSTRING (@OBJECT , 1 , 6)) != (SELECT 'TD_'+ SUBSTRING (DB_NAME(), 1 ,3))
		BEGIN
			RAISERROR ('Cannot create Trigger, Name of Trigger should start with TD_ followed by first three letters of database name, Eg:TD_Adv for Adventure database' ,16, 1  )
			ROLLBACK
		END	*/
END		

 		



GO

SET ANSI_NULLS OFF
GO

SET QUOTED_IDENTIFIER OFF
GO

DISABLE TRIGGER [tu_mod_trgr_checkname] ON DATABASE
GO

ENABLE TRIGGER [tu_mod_trgr_checkname] ON DATABASE
GO


