#!/usr/bin/python

# import modules
import os
import numpy as np
import scipy.stats as sc
import MySQLdb
from array import array

# set Env
homePath = os.getenv('HOME')
fo = open(homePath + '/.mysql_conf','r')
#tmpRead = fo.readlines()

for line in fo.readlines():
    if line.split(':')[0]=='userNm':
        userNm = line.split(':')[1].replace('\n', '')
    elif line.split(':')[0]=='passWd':
        passWd = line.split(':')[1].replace('\n', '')
    elif line.split(':')[0]=='hostNm':
        hostNm = line.split(':')[1].replace('\n', '')
    elif line.split(':')[0]=='portNo':
        portNo = int(line.split(':')[1].replace('\n', ''))

# connect to DB
db = MySQLdb.connect(
    host=hostNm,
    port=portNo,
    user=userNm,
    passwd=passWd,
    db="CMIS"
    )

# assign DB cursor
cur = db.cursor()

# check numpy "corrcoef" function
#cur.execute("select sum(TBL8.numeratorCorr) / (sqrt(sum(TBL8.dominatorTtmUsd) * sum(TBL8.dominatorN225Price))) from(select (TBL7.varianceTtmUsd * TBL7.varianceN225Price) as numeratorCorr, power(TBL7.varianceTtmUsd, 2) as dominatorTtmUsd, power(TBL7.varianceN225Price, 2) as dominatorN225Price from(select (TBL1.TTM_USD - TBL6.avgTtmUsd) as varianceTtmUsd, (TBL2.PRICE_NIKKEI225 - TBL6.avgN225Price) as varianceN225Price from BIG_EX_EXCHANGE_RATE TBL1 inner join BIG_EX_NIKKEI225_PRICE TBL2 on (TBL1.DATEYMD=TBL2.DATEYMD) left outer join(select avg(TBL5.TTM_USD) as avgTtmUsd, avg(TBL5.PRICE_NIKKEI225) as avgN225Price from(select TBL3.TTM_USD, TBL4.PRICE_NIKKEI225 from BIG_EX_EXCHANGE_RATE TBL3 inner join BIG_EX_NIKKEI225_PRICE TBL4 on (TBL3.DATEYMD=TBL4.DATEYMD)) as TBL5) as TBL6 on 1=1) as TBL7) as TBL8")

# extra data from DB
cur.execute("select TBL1.PRICE_NIKKEI225, TBL2.TTM_USD, TBL3.VOLATILITY_NIKKEI225, TBL4.PRICE_DOWJONES, TBL5.PRICE_WTI from BIG_EX_NIKKEI225_PRICE TBL1 inner join BIG_EX_EXCHANGE_RATE TBL2 on (TBL1.DATEYMD=TBL2.DATEYMD) inner join BIG_EX_NIKKEI225_VOLATILITY TBL3 on (TBL1.DATEYMD=TBL3.DATEYMD) inner join BIG_EX_DOWJONES_PRICE TBL4 on (TBL1.DATEYMD=TBL4.DATEYMD) inner join BIG_EX_WTI_PRICE TBL5 on (TBL1.DATEYMD=TBL5.DATEYMD)")

resultOfQuery = cur.fetchall()
arrayOfAllData = []

recCnt = 0

for row in resultOfQuery:
    for index in enumerate(resultOfQuery[0]):
        if recCnt==0:
            assignExpr = "arrayOfAllData" + str(index[0]) + " = []"
            exec(assignExpr)
        assignExpr = "arrayOfAllData" + str(index[0]) + ".append(" + str(row[index[0]]) +")"
        exec(assignExpr)
    recCnt = recCnt + 1

# reset connection to DB
db.close()

# check correlation
for index in enumerate(resultOfQuery[0]):
    if index[0]>0:
        assignExpr = "corrRate = sc.pearsonr(arrayOfAllData0,arrayOfAllData" + str(index[0]) + ")"
        exec(assignExpr)

# get regression
        if abs(corrRate[0])>=0.7:
            assignExpr = "slope, intercept = np.polyfit(arrayOfAllData0,arrayOfAllData" + str(index[0])  + ",1)"
            exec(assignExpr)
            regForm = "N225 = " + str(slope) + "*" + "X" + str(index[0]) + " + " + str(intercept)
            print regForm
