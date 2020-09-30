rem **** E DRIVE ****

E:
cd \
MKDIR "Program Files"

cd "Program Files"
MKDIR "Microsoft SQL Server"

CD \
MKDIR "Program Files (x86)"

cd "Program Files (x86)"
MKDIR "Microsoft SQL Server"


rem **** L Drive ****

L:
MKDIR SYSTEMDB
CD \

L:
cd BACKUP01
MKDIR MSSQL

cd MSSQL
MKDIR CONSQLPRDL

CD CONSQLPRDL
MKDIR BACKUP01
CD \

L:

cd DATA01
MKDIR MSSQL

cd MSSQL
MKDIR CONSQLPRDL

CD CONSQLPRDL
MKDIR DATA01
CD \
L:


cd TEMPDB01
MKDIR MSSQL

cd MSSQL
MKDIR CONSQLPRDL

CD CONSQLPRDL
MKDIR TEMPDB01
CD \

L:
cd TRAN01
MKDIR MSSQL

cd MSSQL
MKDIR CONSQLPRDL

CD CONSQLPRDL
MKDIR TRAN01
