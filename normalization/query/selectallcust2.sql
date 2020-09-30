SELECT c2.custnum, c2.fn, c2.ln,
		a2.custnum, a2.addr, a2.city, a2.st, a2.zp
	FROM [dbo].[custtable2] c2
		JOIN [dbo].[addrtable2] a2 ON (a2.custnum = c2.custnum)