USE [form0]
GO

INSERT INTO [dbo].[addrtable2]
           ([custnum]
           ,[addr]
           ,[city]
           ,[st]
           ,[zp])
SELECT [custnum]
      ,[addr1]
      ,[city1]
      ,[st1]
      ,[zp1]
  FROM [dbo].[custtable1]
GO


