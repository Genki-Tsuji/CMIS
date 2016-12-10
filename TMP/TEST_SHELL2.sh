#!/bin/bash

DATA_AREA=${HOME}/CMIS/DATA
TEMP_AREA=${HOME}/CMIS/TMP

MASTER_wti=${DATA_AREA}/wti_rate.csv
UPDATE_wti=${TEMP_AREA}/DCOILWTICO.csv

REC_CNT_M=`wc -l ${MASTER_wti} | awk '{print $1}'`

LAST_DATE_M=`cat ${MASTER_wti} | awk -F',' -v LASTROW=${REC_CNT_M} '{ if(NR==LASTROW) print $1}' | tr -d '\"-/'`

cat ${UPDATE_wti} | awk -F',' -v UPDATE_DATE=20160509 '{ gsub("-", "", $1) ; if( $1 >= UPDATE_DATE ) print substr($1, 1, 4)"-"substr($1, 5, 2)"-"substr($1, 7, 2)","$2 }'
