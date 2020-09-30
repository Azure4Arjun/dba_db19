USE [form0]
GO

	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

DECLARE @cmd		nvarchar(4000)
DECLARE @obj_name	nvarchar(128)

DECLARE trunc_cur CURSOR FOR
	SELECT o.name
		FROM sys.objects o
	WHERE o.type = 'U' AND
		o.name <> 'sysdiagrams'
		ORDER BY o.object_id DESC;

OPEN trunc_cur;

FETCH NEXT FROM trunc_cur 
	INTO
		@obj_name;

WHILE (@@FETCH_STATUS = 0)
	BEGIN
		SET @cmd = 'TRUNCATE TABLE ' + @obj_name;

		PRINT @cmd
		EXEC (@cmd)

		FETCH NEXT FROM trunc_cur 
			INTO
				@obj_name;
	END

CLOSE trunc_cur;

DEALLOCATE trunc_cur;

