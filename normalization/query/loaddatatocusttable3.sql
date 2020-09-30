USE [form0]
GO

INSERT INTO [dbo].[custtable3]
           ([custnum]
           ,[fn]
           ,[ln])
SELECT [custnum]
      ,[fn]
      ,[ln]
  FROM [dbo].[custtable2]
GO


