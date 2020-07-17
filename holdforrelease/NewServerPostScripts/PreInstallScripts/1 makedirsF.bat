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


rem **** F Drive ****

F:
MKDIR SYSTEMDB
CD \

F:
cd BACKUP01
MKDIR MSSQL

cd MSSQL
MKDIR CONSQLPRDJ

CD CONSQLPRDJ
MKDIR BACKUP01
CD \

F:

cd DATA01
MKDIR MSSQL

cd MSSQL
MKDIR CONSQLPRDJ

CD CONSQLPRDJ
MKDIR DATA01
CD \
F:


cd TEMPDB01
MKDIR MSSQL

cd MSSQL
MKDIR CONSQLPRDJ

CD CONSQLPRDJ
MKDIR TEMPDB01
CD \

F:
cd TRAN01
MKDIR MSSQL

cd MSSQL
MKDIR CONSQLPRDJ

CD CONSQLPRDJ
MKDIR TRAN01
