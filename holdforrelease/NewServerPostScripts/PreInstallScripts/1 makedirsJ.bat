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

J:
MKDIR SYSTEMDB
CD \

J:
cd BACKUP01
MKDIR MSSQL

cd MSSQL
MKDIR CONSQLPRDJ

CD CONSQLPRDJ
MKDIR BACKUP01
CD \

J:

cd DATA01
MKDIR MSSQL

cd MSSQL
MKDIR CONSQLPRDJ

CD CONSQLPRDJ
MKDIR DATA01
CD \
J:


cd TEMPDB01
MKDIR MSSQL

cd MSSQL
MKDIR CONSQLPRDJ

CD CONSQLPRDJ
MKDIR TEMPDB01
CD \

J:
cd TRAN01
MKDIR MSSQL

cd MSSQL
MKDIR CONSQLPRDJ

CD CONSQLPRDJ
MKDIR TRAN01
