--=================================================================
-- Author:		Aron E. Tekulsky
-- Create date: 11/10/09
-- Description: Script to move model off of the c drive to an 
--              alternate drive .
--=================================================================

ALTER DATABASE QuestWorkDatabase MODIFY FILE (NAME = QuestWorkDatabase_Data, FILENAME = 'F:\Program Files\Microsoft SQL Server\MSSQL.1\MSSQL\Data\QuestWorkDatabase_Data.mdf')
GO

ALTER DATABASE QuestWorkDatabase MODIFY FILE (NAME = QuestWorkDatabase_Log, FILENAME = 'S:\Program Files\Microsoft SQL Server\MSSQL.1\MSSQL\Log\QuestWorkDatabase_Log.ldf')
GO

ALTER DATABASE SpotlightPlaybackDatabase MODIFY FILE (NAME = SpotlightPlaybackDatabase_Data, FILENAME = 'F:\Program Files\Microsoft SQL Server\MSSQL.1\MSSQL\Data\SpotlightPlaybackDatabase_Data.mdf')
GO

ALTER DATABASE SpotlightPlaybackDatabase MODIFY FILE (NAME = SpotlightPlaybackDatabase_Log, FILENAME = 'S:\Program Files\Microsoft SQL Server\MSSQL.1\MSSQL\Log\SpotlightPlaybackDatabase_Log.ldf')
GO

ALTER DATABASE SpotlightStatisticsRepository MODIFY FILE (NAME = SpotlightStatisticsRepository_Data, FILENAME = 'F:\Program Files\Microsoft SQL Server\MSSQL.1\MSSQL\Data\SpotlightStatisticsRepository_Data.mdf')
GO

ALTER DATABASE SpotlightStatisticsRepository MODIFY FILE (NAME = SpotlightStatisticsRepository_Log, FILENAME = 'S:\Program Files\Microsoft SQL Server\MSSQL.1\MSSQL\Log\SpotlightStatisticsRepository_Log.ldf')
GO

