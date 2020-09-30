USE [form0]
GO

INSERT INTO [dbo].[custtable2]
           ([custnum]
           ,[fn]
           ,[ln])
SELECT [custnum]
      ,[fn]
      ,[ln]
  FROM [dbo].[custtable1]
GO


