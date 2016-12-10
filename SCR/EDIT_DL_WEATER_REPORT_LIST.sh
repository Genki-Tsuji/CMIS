#!/bin/bash

TEMP_AREA=$HOME/CMIS/TMP

YYYY=`date +"%Y"`
MM=`date +"%m"`
DD=`date +"%d"`

REPLACE_SID=`curl -s http://www.data.jma.go.jp/gmd/risk/obsdl/index.php | grep -i 'id="sid" value=' | awk -F'[ =]' '{print $7}' | tr -d '"'`

echo ${REPLACE_SID}

cat ${TEMP_AREA}/DL_WEATHER_REPORT.dat | \
awk '{sub("REPLACE_SID", '${REPLACE_SID}'); print $0}' | \
awk '{sub("TO_YYYY", '${YYYY}'); print $0}' | \
awk '{sub("TO_M", '${MM}'); print $0}' | \
awk '{sub("TO_D", '${DD}'); print $0}' \
> ${TEMP_AREA}/DL_WEATHER_REPORT.lck
