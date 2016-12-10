#!/bin/bash

# Set Environment
DATA_AREA=${HOME}/CMIS/DATA
TEMP_AREA=${HOME}/CMIS/TMP
WIN_AREA=/win
EXE_DATE=`date "+%Y%m%d"`
EXE_SH=`basename ${0} .sh`

# Deffine MasterFile
MASTER_225=${DATA_AREA}/nikkei_225_index.csv
UPDATE_225=${TEMP_AREA}/nikkei_stock_average_daily_jp.csv

MASTER_225_vi=${DATA_AREA}/nikkei_225_volindex.csv
UPDATE_225_vi=${TEMP_AREA}/nikkei_stock_average_vi_daily_jp.csv

MASTER_exchrr=${DATA_AREA}/exchange_rate.csv
UPDATE_exchrr=${TEMP_AREA}/quote.csv

MASTER_dow=${DATA_AREA}/dow_jones_industrial.csv
UPDATE_dow=${TEMP_AREA}/dow_jones_industrial_newest.csv

MASTER_wti=${DATA_AREA}/wti_rate.csv
UPDATE_wti=${TEMP_AREA}/DCOILWTICO.csv

MASTER_icm=${DATA_AREA}/i_commodity.csv
UPDATE_icm=${TEMP_AREA}/i-mizuho-commodity-index

# Set Var to reference for to UpdateFile
UPDATE_FILE_LIST="225 225_vi exchrr dow wti icm"

# Data Cleaning 
sed -e '$d' ${UPDATE_225} > ${TEMP_AREA}/UPDATE_225_TMP.dat
mv ${TEMP_AREA}/UPDATE_225_TMP.dat ${UPDATE_225}

sed -e '$d' ${UPDATE_225_vi} > ${TEMP_AREA}/UPDATE_225_vi_TMP.dat
mv ${TEMP_AREA}/UPDATE_225_vi_TMP.dat ${UPDATE_225_vi}

cat ${TEMP_AREA}/"download?MOD_VIEW"* | awk -F'[/,]' -v OFS=, 'NR > 1 {print 20$3"/"$1"/"$2,$4,$5,$6,$7}' | sort -k1 > ${UPDATE_dow}

NAV_VALUE=`grep -i -A 1 'nav-value' ${TEMP_AREA}/i-mizuho-commodity-index | awk 'NR==2 {print substr($0, 3, length($0) - 1);}' | tr -d '\r' | tr -d ','`
AS_OF_DATE=`grep -i -A 1 'as-of-date' ${TEMP_AREA}/i-mizuho-commodity-index | awk 'NR==2 {print $2}'  | tr -d '\r'`

echo "$AS_OF_DATE,$NAV_VALUE" > ${UPDATE_icm}

for ARG in $UPDATE_FILE_LIST 
do

  MASTER=`eval echo '$'{MASTER_${ARG}}`
  UPDATE=`eval echo '$'{UPDATE_${ARG}}`

  # Check MasterFile Record Count
  REC_CNT_M=`wc -l ${MASTER} | awk '{print $1}'`

  # Check MasterFile LastDate
  LAST_DATE_M=`cat ${MASTER} | awk -F',' -v LASTROW=${REC_CNT_M} '{ if(NR==LASTROW) print $1}' | tr -d '\"'`

  # Check UpdateFile Record Count
  REC_CNT_U=`wc -l ${UPDATE} | awk '{print $1}'`

  # Check UpdateFile LastDate
  LAST_DATE_U=`cat ${UPDATE} | awk -F',' -v LASTROW=${REC_CNT_U} '{ if(NR==LASTROW) print $1}' | tr -d '\"'`

echo ${ARG} >> ${TEMP_AREA}/${EXE_SH}${EXE_DATE}.log
echo "**********debug**********" >> ${TEMP_AREA}/${EXE_SH}${EXE_DATE}.log
  echo ${LAST_DATE_M} >> ${TEMP_AREA}/${EXE_SH}${EXE_DATE}.log
  echo ${LAST_DATE_U} >> ${TEMP_AREA}/${EXE_SH}${EXE_DATE}.log
  echo "" >> ${TEMP_AREA}/${EXE_SH}${EXE_DATE}.log
  tail -n 5 ${UPDATE} >> ${TEMP_AREA}/${EXE_SH}${EXE_DATE}.log
  echo "" >> ${TEMP_AREA}/${EXE_SH}${EXE_DATE}.log
echo "**********debug**********" >> ${TEMP_AREA}/${EXE_SH}${EXE_DATE}.log
echo "" >> ${TEMP_AREA}/${EXE_SH}${EXE_DATE}.log

  # Judge Update MasterFile or not
  if [ $LAST_DATE_M != $LAST_DATE_U ]
  then
    echo "update master file : "${MASTER} 

    FILE_NM=`basename ${MASTER}`
    rm -f ${WIN_AREA}/${FILE_NM} 2>&1 1>/dev/null

    if [ ${ARG} != "wti" ]
    then

      UPDATE_RECORD=`cat ${UPDATE} | awk -F',' -v LASTROW=${REC_CNT_U} '{ if(NR==LASTROW) print $0}'`

      echo ${UPDATE_RECORD} >> ${MASTER}
    else

      cat ${UPDATE_wti} | awk -F',' -v UPDATE_DATE=${LAST_DATE_M} '{ gsub("-", "", $1) ; gsub("-", "", UPDATE_DATE) ; if( $1 > UPDATE_DATE && NR >= 2 ) print substr($1, 1, 4)"-"substr($1, 5, 2)"-"substr($1, 7, 2)","$2 }' >> ${MASTER}
    fi

    cp -p ${MASTER} ${WIN_AREA}/${FILE_NM} 2>&1 1>/dev/null

    rm -f ${UPDATE}
    if [ -f ${TEMP_AREA}/"download?MOD_VIEW"* ]
    then
      rm -f ${TEMP_AREA}/"download?MOD_VIEW"*
    fi
  else
    echo "no update master file : "${MASTER}

    rm -f ${UPDATE}
    if [ -f ${TEMP_AREA}/"download?MOD_VIEW"* ]
    then
      rm -f ${TEMP_AREA}/"download?MOD_VIEW"*
    fi
  fi 
done
