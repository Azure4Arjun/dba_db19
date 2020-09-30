USE [form0]
GO

INSERT INTO [dbo].[custtable1]
           ([custnum]
           ,[fn]
           ,[ln]
           ,[addr1]
           ,[city1]
           ,[st1]
           ,[zp1])
SELECT [custnum1]
      ,[fn1]
      ,[ln1]
      ,[addr1]
      ,[city1]
      ,[st1]
      ,[zp1]
  FROM [dbo].[custtable0]






INSERT INTO [dbo].[custtable1]
           ([custnum]
           ,[fn]
           ,[ln]
           ,[addr1]
           ,[city1]
           ,[st1]
           ,[zp1])
SELECT [custnum2]
      ,[fn2]
      ,[ln2]
      ,[addr2]
      ,[city2]
      ,[st2]
      ,[zp2]
  FROM [dbo].[custtable0]



