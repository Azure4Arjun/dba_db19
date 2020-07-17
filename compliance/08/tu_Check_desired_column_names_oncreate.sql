USE [model]
GO

/****** Object:  DdlTrigger [Check_column_name]    Script Date: 07/28/2009 16:09:22 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TRIGGER [tu_check_desired_column_names_oncreate]
ON DATABASE
FOR CREATE_TABLE
AS
IF NOT EXISTS
(
   SELECT
      Table_Name
  FROM
        INFORMATION_SCHEMA.COLUMNS
  WHERE
       Table_Name = EVENTDATA().value('(/EVENT_INSTANCE/ObjectName)[1]', 'nvarchar(128)')
      AND IS_NULLABLE = 'NO'
      AND
        (
           (
               Column_Name COLLATE SQL_Latin1_General_CP1_CS_AS = 'sql_id' COLLATE SQL_Latin1_General_CP1_CS_AS
                AND DATA_TYPE = 'varchar'
               AND CHARACTER_MAXIMUM_LENGTH = 20
           )
           OR
         (
               Column_Name COLLATE SQL_Latin1_General_CP1_CS_AS = 'user_id' COLLATE SQL_Latin1_General_CP1_CS_AS
               AND DATA_TYPE = 'varchar'
               AND CHARACTER_MAXIMUM_LENGTH = 20
           )
           OR
         (
               Column_Name COLLATE SQL_Latin1_General_CP1_CS_AS = 'creation_date' COLLATE SQL_Latin1_General_CP1_CS_AS
             AND DATA_TYPE = 'datetime'
         )
           OR
         (
               Column_Name COLLATE SQL_Latin1_General_CP1_CS_AS = 'last_modified_date' COLLATE SQL_Latin1_General_CP1_CS_AS
                AND DATA_TYPE = 'datetime'
         )
           OR
         (
               Column_Name COLLATE SQL_Latin1_General_CP1_CS_AS = 'lkp_row_status' COLLATE SQL_Latin1_General_CP1_CS_AS
                AND DATA_TYPE = 'char'
              AND CHARACTER_MAXIMUM_LENGTH = 1
            )
       )
   GROUP BY
        Table_Name
  HAVING
      COUNT(*) = 5
)
BEGIN
  RAISERROR ('Table structure invalid.Please read dbpolicy_fordevfelopers.doc', 16, 1);
   ROLLBACK;
END




GO

SET ANSI_NULLS OFF
GO

SET QUOTED_IDENTIFIER OFF
GO

DISABLE TRIGGER [tu_check_desired_column_names_oncreate] ON DATABASE
GO

ENABLE TRIGGER [tu_check_desired_column_names_oncreate] ON DATABASE
GO


