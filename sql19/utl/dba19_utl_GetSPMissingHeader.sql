SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- ======================================================================================
-- dba19_utl_GetSPMissingHeader
--
--
-- Calls:		None
--
-- Description:	Create new sp script with a header.
-- 
-- Date			Modified By			Changes
-- 09/25/2012   Aron E. Tekulsky    Initial Coding.
-- 10/31/2017   Aron E. Tekulsky    Update to Version 140.
-- 08/26/2020   Aron E. Tekulsky    Update to Version 150.
-- ======================================================================================
--	Copyright©2001 - 2025 Aron Tekulsky.  World wide rights reserved.
--	Use of this code is free of charge but does not in any way imply transfer of 
--	Copyright ownership to the user.
--
--  This code and information are provided "AS IS" without warranty of
--  any kind, either expressed or implied, including but not limited
--  to the implied warranties of merchantability and/or fitness for a
--  particular purpose.
-- ======================================================================================
--
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;

	DECLARE @headr1			nvarchar(4000)
	DECLARE @headr2			nvarchar(4000)
	DECLARE @headr3			nvarchar(4000)
	DECLARE @headr4			nvarchar(4000)
	DECLARE @headr5			nvarchar(4000)
	DECLARE @headr6			nvarchar(4000)
	DECLARE @headr7			nvarchar(4000)
	DECLARE @headr8			nvarchar(4000)
	DECLARE @headr9			nvarchar(4000)
	DECLARE @headr10		nvarchar(4000)
	DECLARE @headr11		nvarchar(4000)
	DECLARE @headr12		nvarchar(4000)

	DECLARE @headr13		nvarchar(4000)
	DECLARE @headr14		nvarchar(4000)
	DECLARE @headr15		nvarchar(4000)
	DECLARE @headr16		nvarchar(4000)
	DECLARE @headr17		nvarchar(4000)
	DECLARE @headr18		nvarchar(4000)
	DECLARE @headr19		nvarchar(4000)

	DECLARE	@altr_def		char(6)
	DECLARE @bal_def		nvarchar(4000)
	DECLARE @caller			nvarchar(128)

	DECLARE @CopyRight		nvarchar(4000)

	DECLARE	@crdate			datetime
	DECLARE @crdate_txt		nvarchar(100)
	DECLARE @crlf			nvarchar(100)
	DECLARE @curdate_txt	nvarchar(100)
	DECLARE	@def_val		sql_variant
	DECLARE @description	nvarchar(255)
	DECLARE @finalheader	nvarchar(4000)
	DECLARE	@isoutput		bit
	DECLARE @moddate_txt	nvarchar(100)
	DECLARE	@moddt			datetime
	DECLARE	@new_def		nvarchar(4000)
	DECLARE	@param			nvarchar(128)
	DECLARE	@param_id		int
	DECLARE @parameter		nvarchar(128)	
	--DECLARE @theedate		datetime
	DECLARE @procname		nvarchar(128)
	DECLARE	@proc_tye		char(2)
	DECLARE @rowcnt			int
	DECLARE @spname			nvarchar(128)
	DECLARE	@txt			nvarchar(4000)

	--DECLARE @crloc			int



	SET @altr_def = 'ALTER ';

	SET @crlf	= CHAR(13) + CHAR(10);

	SET @parameter	= '';
	SET @moddt	= getdate();
	----SET @procname	= 	'p_dba_get_expired_db';
	SET @procname	= 	'';
	SET @caller		= 'None ';
	SET @description = 'testing';


	SET @headr1 = '-- ====================================================================================== ' + @crlf;
	SET @headr2 = '-- ' ;
	--p_dba_get_expired_db
	--SET @headr2 = '--'
	SET @headr3 = '-- Arguments:	' + @parameter + ' ' + @crlf;
	SET @headr4 = '			        ' + @crlf;
	--SET @headr2 = '--'
	SET @headr5 = '-- Called BY:	' + @caller + ' ' + @crlf;
	--SET @headr2 = '--'
	SET @headr6 = '-- Description:	' + @description + ' ' + @crlf;
	--SET @headr2 = '-- '
	SET @headr7 = '-- Date			Modified By			Changes'
	+ ' ' + @crlf;
	--SET @headr8 = '-- ' + convert(varchar(100),@moddt, 101) + '   Aron E. Tekulsky    Initial Coding.'
	SET @headr8 = '-- ' + convert(varchar(100),@crdate, 101) + 
	'   Developer    Initial Coding.' + ' ' + @crlf;
	SET @headr11 = '-- ' + convert(varchar(100),@moddt, 101) +
	'   Developer    Additional Coding.' + ' ' + @crlf;
	SET @headr12 = '-- ' + convert(varchar(100),getdate(), 101) +
	'   Aron E. Tekulsky    Add headings.' + ' ' + @crlf;

	SET @headr9 = '--           	' + @parameter + ' ' + @crlf;

	SET @headr10 = '-- ' + @crlf;

	--SET @headr1 = '-- ============================================='


	SET @headr13 = '--	Copyright©2001 - 2025 Aron Tekulsky.  World wide rights reserved.' + ' ' + @crlf;
	SET @headr14 = '--	Use of this code is free of charge but does not in any way imply transfer of' + ' ' + @crlf;
	SET @headr15 = '--	Copyright ownership to the user.' + ' ' + @crlf;
	SET @headr16 = '--  This code and information are provided "AS IS" without warranty of' + ' ' + @crlf;
	SET @headr17 = '--  any kind, either expressed or implied, including but not limited' + ' ' + @crlf;
	SET @headr18 = '--  to the implied warranties of merchantability and/or fitness for a' + ' ' + @crlf;
	SET @headr19 = '--  particular purpose.' + ' ' + @crlf;

	SET @CopyRight = @headr13 + @headr14 + @headr15 + @headr10 + @headr16 + @headr17 + 
		@headr18 + @headr19 + @headr1 + @headr10; 

			SET @rowcnt = 0;

			DECLARE hdr_cur CURSOR FOR
				SELECT p.name, p.create_date, p.modify_date, p.type,  --p.[object_id], p.[principal_id], p.[schema_id], p.[parent_object_id],
							a.name as param_eters, a.[parameter_id],-- a.[system_type_id], a.[user_type_id],
							a.[is_output], --a.[has_default_value],
							a.[default_value],
							 c.text--,
					FROM sys.procedures p
						LEFT JOIN [sys].[parameters]  a ON (p.[object_id] = a.[object_id])
						LEFT JOIN [sys].[types]       t ON (a.[user_type_id] = t.[user_type_id])
						LEFT JOIN [sys].[syscomments] c ON (p.[object_id] = c.id)
						LEFT JOIN [sys].[sql_modules] s ON (p.[object_id] = s.[object_id])
				WHERE 
				----WHERE p.name like 'p_%' AND
				----------WHERE p.name like '%' AND
					(charindex('CREATE PROCEDURE', upper(s.definition)) - 1) < 10
					--AND p.name = 'p_arontest2'
				ORDER BY p.name ASC, a.[parameter_id] ASC, c.colid ASC;

				OPEN hdr_cur;

				FETCH hdr_cur INTO
					@spname, @crdate, 	@moddt, @proc_tye, @param, 	@param_id, @isoutput, @def_val, @txt;

				SET @procname = @spname;

				WHILE (@@FETCH_STATUS = 0)
					BEGIN
					
						SET @rowcnt = @rowcnt + 1;

						IF @rowcnt = 1
							BEGIN
								SET @procname = @spname
								SET @crdate_txt  = convert(varchar(100), @crdate, 101);
								SET @moddate_txt = convert(varchar(100), @moddt, 101);
								SET @curdate_txt = convert(varchar(100), getdate(), 101);

								--SET @headr8 = '-- ' + convert(varchar(100),@crdate, 101) + '   Aron E. Tekulsky    Initial Coding.'  + @crlf
								--SET @headr8 = '-- ' + convert(varchar(100),@crdate, 101)   + '   Developer           Initial Coding.' + ' ' + @crlf
								--SET @headr11 = '-- ' + convert(varchar(100),@moddt, 101)   + '   Developer           Additional Coding.' + ' ' + @crlf
								--SET @headr12 = '-- ' + convert(varchar(100), getdate(), 101) + '   Aron E. Tekulsky    Add headings.' + ' ' + @crlf

								SET @headr8 = '-- ' + @crdate_txt     +
								'   Developer           Initial Coding.' + ' ' + @crlf;
								SET @headr11 = '-- ' + @moddate_txt   + 
								'   Developer           Additional Coding.' + ' ' + @crlf;
								SET @headr12 = '-- ' +
								@curdate_txt   + '   Aron E. Tekulsky    Add headings.' + ' ' + @crlf;

								SET @finalheader = @headr1 + @headr2 + @procname + @crlf+ @headr10;

								--SET @crloc = CHARINDEX ('CREATE ', UPPER(@txt)) ;
								SET @bal_def = SUBSTRING (@txt, 7, LEN(@txt));

								--print   @bal_def;
								
							END

						IF (@spname <> @procname)
						-- we have a new sp so print last one
							BEGIN
								SET @finalheader =  @finalheader + @headr4 + @headr10 + 
									@headr5 + @headr10 + @headr6 + @headr2 + @crlf + @headr7 + @headr8 ;
								
								IF @moddate_txt IS NOT NULL AND (@moddate_txt <> @crdate_txt)
									SET @finalheader =  @finalheader + @headr11+ @headr12 + @headr1;
								ELSE
									SET @finalheader =  @finalheader + @headr12 + @headr1;

										--PRINT @finalheader
										--PRINT @txt

								SET @new_def = @finalheader + ' ' + @altr_def + @bal_def + ' ' + ';';

								PRINT @new_def;
								------EXEC (@new_def)

								PRINT @CopyRight;

								-- reset for the next sp
								SET @rowcnt = 0;
								SET @procname = @spname;
							
							END

						ELSE
						-- same one
							BEGIN

								SET @parameter = @param;

								IF @rowcnt = 1
									BEGIN
										SET @headr3 = '-- Arguments:	' + ISNULL(@parameter, 'None.') + @crlf;
										SET @finalheader = @finalheader + @headr3 ;
									END
								ELSE
									BEGIN
										SET @headr9 = '--           	' + @parameter + ' ';
										SET @finalheader = @finalheader + @headr9;
									END
							END


						FETCH hdr_cur INTO
							@spname, @crdate, 	@moddt, @proc_tye, @param, 	@param_id, @isoutput, @def_val, @txt;

					END


					CLOSE hdr_cur;

					DEALLOCATE hdr_cur;
				
					--SET @finalheader =  @finalheader + @headr4 + @headr10 + @headr5 + @headr10 + 
					--					@headr6 + @headr10 + @headr7 + @headr8 + @headr11 + @headr12 + @headr1;

					SET @finalheader =  @finalheader + @headr4 + @headr10 + @headr5 + 
						@headr10 + @headr6 + @headr2 + @crlf + @headr7 + @headr8 ;

					IF @moddate_txt IS NOT NULL AND (@moddate_txt <> @crdate_txt)

						SET @finalheader =  @finalheader + @headr11 + @headr12 + @headr1;

					ELSE
						SET @finalheader =  @finalheader + @headr12 + @headr1;

					------PRINT @CopyRight;


					--PRINT @finalheader;
					--PRINT @txt;

					------SET @new_def = @finalheader + ' ' + @altr_def + @bal_def + ' ' + ';';
					SET @new_def = @finalheader + ' ' + @CopyRight + ' ' + @altr_def + @bal_def + ' ' + ';';

					PRINT @new_def;


					------EXEC (@new_def);


END
GO
