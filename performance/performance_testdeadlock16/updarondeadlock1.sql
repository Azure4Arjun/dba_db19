USE [test5]
go

BEGIN TRAN
	UPDATE [dbo].[arondeadlock1]
		SET [bspid] = [bspid]
	WHERE [bspid] = 1;
