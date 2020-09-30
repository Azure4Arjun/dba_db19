-- ***** blocked *****
DECLARE @icount	int

SET @icount = 0;

WHILE (@icount < 500)
	BEGIN
BEGIN TRAN
		SELECT *
			FROM [test5].[dbo].[aronspid];

		WAITFOR DELAY '00:00:03'


	SET @icount = @icount + 1;
	END
