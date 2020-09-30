USE [test5]
go
BEGIN TRAN
	UPDATE [dbo].[arondeadlock2]
		SET [bspid] = [bspid]
	WHERE [bspid] = 1;

	UPDATE [dbo].[arondeadlock1]
		SET [bspid] = [bspid]
	WHERE [bspid] = 1;
