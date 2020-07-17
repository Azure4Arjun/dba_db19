USE [sox]
GO

/****** Object:  StoredProcedure [dbo].[p_sox_get_dbevents_all_by_date]    Script Date: 6/29/2012 2:13:17 PM ******/
DROP PROCEDURE [dbo].[p_sox_get_dbevents_all_by_date]
GO

/****** Object:  StoredProcedure [dbo].[p_sox_get_dbevents_all_by_date]    Script Date: 6/29/2012 2:13:17 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO






-- ==============================================================
-- p_sox_get_dbevents_all_by_date
--
-- Arguments:	None
--				None
--
-- Called BY:	None
--
-- Description:	Get a listing of all the database events that 
--				took place on the server during a specific period.
-- 
-- Date			Modified By			Changes
-- 06/26/2012   Aron E. Tekulsky    Initial Coding.
-- ==============================================================
CREATE PROCEDURE [dbo].[p_sox_get_dbevents_all_by_date] 
	-- Add the parameters for the stored procedure here
	@startdatetime	nvarchar(50),
	@enddatetime	nvarchar(50)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here

    IF @startdatetime is NULL OR @startdatetime = ''
		BEGIN
			--SET @startdatetime = dateadd(dd,-1,convert(varchar(50),getdate(),101))
			SET @startdatetime = dateadd(dd,-1,getdate())
			--SET @startdatetime = getdate()
		END

	ELSE
		BEGIN
			SET @startdatetime = convert(datetime,@startdatetime,101)
		END


	IF  @enddatetime IS NULL or @enddatetime = ''
		BEGIN
			--SET @enddatetime = dateadd(dd,1,convert(varchar(50),getdate(),101))
			SET @enddatetime = dateadd(dd,1,getdate())
		END
				
	ELSE
		BEGIN
			SET @enddatetime = convert(datetime,@enddatetime,101)
		END


	SELECT l.ServerName, l.DatabaseName, l.EventTime, l.EventType, l.ObjectType, l.ObjectName, l.UserName, 
		CASE 
			WHEN charindex('REORGANIZE',[CommandText],1) > 0 THEN
				'REORGANIZE'
			WHEN charindex('REBUILD',[CommandText],1) > 0 THEN
				'REBUILD'
		END AS idx_action
--, l.CommandText
		FROM tblDDLEventLog l
	WHERE datediff(day, @startdatetime,EventTime) >= 0 AND
		  datediff(day, @enddatetime ,EventTime) <= 0
	--WHERE datediff(day, ''' + @startdatetime + ''',EventTime) >= 0 AND
	--	  datediff(day, ''' + @enddatetime + ''' ,EventTime) <= 0
	ORDER BY l.ServerName ASC, l.EventTime DESC, l.DatabaseName ASC 

	IF @@ERROR <> 0 GOTO ErrorHandler

	RETURN 1

	ErrorHandler:
	RETURN -1 
END






GO

GRANT EXECUTE ON [dbo].[p_sox_get_dbevents_all_by_date] TO [db_proc_exec] AS [dbo]
GO


