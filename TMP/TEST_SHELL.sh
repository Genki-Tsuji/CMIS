#!/bin/bash

DATA_AREA=${HOME}/CMIS/DATA
TEMP_AREA=${HOME}/CMIS/TMP

MASTER_icm=${DATA_AREA}/i_commodity.csv
UPDATE_icm=${TEMP_AREA}/i-mizuho-commodity-index

NAV_VALUE=`grep -i -A 1 'nav-value' i-mizuho-commodity-index | awk 'NR==2 {print substr($0, 3, length($0) - 1);}' | tr -d '\r' | tr -d ','`
AS_OF_DATE=`grep -i -A 1 'as-of-date' i-mizuho-commodity-index | awk 'NR==2 {print $2}' | awk -F'/' '{print $0}' | tr -d '\r'`
echo "$AS_OF_DATE,$NAV_VALUE" > ${UPDATE_icm}2
