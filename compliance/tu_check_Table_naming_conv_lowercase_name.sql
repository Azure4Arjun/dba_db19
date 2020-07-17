

/****** Object:  DdlTrigger [tu_check_table_naming_conv_lowercase_name]    Script Date: 07/28/2009 17:38:54 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


CREATE TRIGGER [tu_check_table_naming_conv_lowercase_name]
ON DATABASE 
for CREATE_TABLE,ALTER_TABLE
AS
BEGIN

    DECLARE @data XML;
    DECLARE @object sysname;
    SET @data = EVENTDATA();
    SET @object = @data.value('(/EVENT_INSTANCE/ObjectName)[1]', 'sysname') 
    Print @object
	IF (SELECT SUBSTRING (@object , 1 , 4)) Not Like('[a-z][a-z][a-z][_]%')
	 OR
	@object COLLATE SQL_Latin1_General_CP1_CS_AS <> 
          LOWER(@object) COLLATE SQL_Latin1_General_CP1_CS_AS
 --!= (SELECT  SUBSTRING (DB_NAME(), 1 ,3)+'_')
		BEGIN
			RAISERROR ('Cannot create Table,Follow this format ''adv_'' positions 1,2,3 must be alphabets & position 4 must be an underscore and all lowercase' ,16, 1  )
			ROLLBACK
		END
END		
		
GO

SET ANSI_NULLS OFF
GO

SET QUOTED_IDENTIFIER OFF
GO




