SELECT c3.custnum, c3.fn, c3.ln,
		a3.custnum, a3.addr, a3.zp,
		z3.city, z3.st, z3.zp
	FROM [dbo].[custtable3] c3
		JOIN [dbo].[addrtable3] a3 ON (a3.custnum= c3.custnum)
		JOIN [dbo].[ziptable3] z3 ON (a3.zp =  z3.zp)

