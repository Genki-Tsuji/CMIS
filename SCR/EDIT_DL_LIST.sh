#!/bin/bash

TEMP_AREA=$HOME/CMIS/TMP

YYYY=`date +"%Y"`
MM=`date +"%m"`
DD=`date +"%d"`

awk '{sub("MM/DD/YYYY", '${MM}'"/"'${DD}'"/"'${YYYY}'); print $0}' \
${TEMP_AREA}/DL_LIST.dat > ${TEMP_AREA}/DL_LIST.lck
