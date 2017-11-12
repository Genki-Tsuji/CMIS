#!/bin/bash
# Set Configfile
configFile=${HOME}/.mysql_conf

# Set Username 
userNm=`grep userNm ${configFile} | awk -F':' '{print $2}'`
passWd=`grep passWd ${configFile} | awk -F':' '{print $2}'`
hostNm=`grep hostNm ${configFile} | awk -F':' '{print $2}'`

# Generate Load Module
### 1.connect ### 
useDbPart='--database='
dbNm='CMIS '
accessModulue="mysql -h ${hostNm} -P 3306 -u ${userNm} --password=${passWd} ${useDbPart}${dbNm} "

# ======debug echo ${accessModulue} debug======

### 2.load ### 
infilePart='load data local infile '
externalFileNm=`grep externalFileNm $1 | awk -F":" '{print $2}'`
intoTablePart='into table '
tableNm=`grep tableNm $1 | awk -F":" '{print $2}'`
dlmColPart='fields terminated by '
dlmStr=`grep 'fields terminated by' $1 | awk -F":" '{print $2}'`
enclosedDoublequoteChk=`grep 'enclosed by' $1 | awk -F":" '{print $2}'`
if [ "$enclosedDoublequoteChk" = 'Yes' ]; then
  enclosedDoublequote='enclosed by "\"" '
else
  enclosedDoublequote=' '
fi

termStrPart='lines terminated by '
termStr=`grep 'lines terminated by' $1 | awk -F":" '{print $2}'`
ignoreHeadChk=`grep 'ignore 1 lines' $1 | awk -F":" '{print $2}'`
if [ "$ignoreHeadChk" = 'Yes' ]; then
  ignoreHead='ignore 1 lines '
else
  ignoreHead=' '
fi
assignColPart=`grep assignColPart $1 | awk -F":" '{print $2}'`

loadModule="${infilePart}${externalFileNm} ${intoTablePart}${tableNm} ${dlmColPart}${dlmStr} ${enclosedDoublequote} ${termStrPart}${termStr} ${ignoreHead}${assignColPart} ;"

# ======echo ${loadModule} debug======

# Execute SQL
executeSQL=${accessModulue}"--execute="\'${loadModule}\'
eval "$executeSQL"
