--Now how can we find the point at which the table was dropped?

SELECT
    [Current LSN],
    [Operation],
    [Context],
    [Transaction ID],
    [Description]
FROM fn_dblog (NULL, NULL),
    (SELECT [Transaction ID] AS tid FROM fn_dblog (NULL, NULL) WHERE [Transaction Name] LIKE '%DROPOBJ%') fd
WHERE [Transaction ID] = fd.tid;
GO