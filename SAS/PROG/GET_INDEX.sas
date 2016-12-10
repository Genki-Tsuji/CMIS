/* Setting Environment */
%let PATH_NPC = T:\ ;
%let OUT_AREA = C:\Users\Genki\SAS\SAMPLE ;

/* Input Exchange Rate */
filename IN "&PATH_NPC./exchange_rate.csv" ;
run ;

data EXCHANGE_RATE ;
  keep YYYYMMDD
          R_USD
          R_GPB
          R_EUR
          ;
  format YYYYMMDD
            R_USD
            R_GPB
            R_EUR
            ;
  length YYYYMMDD_C $010 ;
  infile IN dlm=',' missover dsd lrecl=10000 firstobs=2 ;
  input YYYYMMDD_C
        R_USD
        R_GPB
        R_EUR
        ;
  YYYYMMDD = input(YYYYMMDD_C, yymmdd10.) ;
run ;

/* Input Nikkei225Index */
filename IN "&PATH_NPC./nikkei_225_index.csv" ;
run ;

data INDEX_225 ;
  keep YYYYMMDD
       LAST_VALUE225
       ;
  format YYYYMMDD
         LAST_VALUE225
         ;
  length YYYYMMDD_C $010 ;
  infile IN dlm=',' missover dsd lrecl=10000 firstobs=2 ;
  input YYYYMMDD_C
        LAST_VALUE225
        ;
  YYYYMMDD = input(YYYYMMDD_C, yymmdd10.) ;
run ;

/* Input Nikkei225VolatilityIndex */
filename IN "&PATH_NPC./nikkei_225_volindex.csv" ;
run ;

data VOLINDEX_225 ;
  keep YYYYMMDD
       LAST_VOLINDEX225
       ;
  format YYYYMMDD
         LAST_VOLINDEX225
         ;
  length YYYYMMDD_C $010 ;
  infile IN dlm=',' missover dsd lrecl=50000 firstobs=2 ;
  input YYYYMMDD_C
        LAST_VOLINDEX225
        ;
  YYYYMMDD = input(YYYYMMDD_C, yymmdd10.) ;
run ;

/* Input DowJonesIndustrial */
filename IN "&PATH_NPC./dow_jones_industrial.csv" ;
run ;

data DOW_JONES ;
  keep YYYYMMDD
       DOW_JONES_AVERAGE
       ;
  format YYYYMMDD
         DOW_JONES_AVERAGE
         ;
  length YYYYMMDD_C $010 ;
  infile IN dlm=',' missover dsd lrecl=50000 firstobs=2 ;
  input YYYYMMDD_C
          @ ','
          @ ','
          @ ','
          DOW_JONES_AVERAGE
          ;
  YYYYMMDD = input(YYYYMMDD_C, yymmdd10.) ;
run ;

/* Input i-mizuho_CommodityIndex */
filename IN "&PATH_NPC./i_commodity.csv" ;
run ;

data COMMODITY ;
  keep YYYYMMDD
       COMMODITY_INDEX
       ;
  format YYYYMMDD
         COMMODITY_INDEX
         ;
  length YYYYMMDD_C $010 ;
  infile IN dlm=',' missover dsd lrecl=50000 ;
  input YYYYMMDD_C
          COMMODITY_INDEX
          ;
  YYYYMMDD = input(YYYYMMDD_C, yymmdd10.) ;
run ;

/* Input WTI */
filename IN "&PATH_NPC./wti_rate.csv" ;
run ;

data WTI ;
  keep YYYYMMDD
       WTI
       ;
  format YYYYMMDD
         WTI
         ;
  length YYYYMMDD_C $010 ;
  infile IN dlm=',' missover dsd lrecl=50000 ;
  input YYYYMMDD_C
          WTI
          ;
  YYYYMMDD = input(YYYYMMDD_C, yymmdd10.) ;
run ;

proc sort data=EXCHANGE_RATE ; by YYYYMMDD ;
run ;

proc sort data=INDEX_225 ; by YYYYMMDD ;
run ;

proc sort data=VOLINDEX_225 ; by YYYYMMDD ;
run ;

proc sort data=DOW_JONES ; by YYYYMMDD ;
run ;

proc sort data=COMMODITY ; by YYYYMMDD ;
run ;

proc sort data=WTI ; by YYYYMMDD ;
run ;

data SAMPLE ;
  keep YYYYMMDD
       R_USD
       R_GPB
       R_EUR
       LAST_VALUE225
       LAST_VOLINDEX225
       DOW_JONES_AVERAGE
       COMMODITY_INDEX
       WTI
       ;
  format YYYYMMDD
         R_USD
         R_GPB
         R_EUR
         LAST_VALUE225
         LAST_VOLINDEX225
         DOW_JONES_AVERAGE
         COMMODITY_INDEX
         WTI
         ;
  merge EXCHANGE_RATE(in=IN1)
        INDEX_225(in=IN2)
        VOLINDEX_225(in=IN3)
        DOW_JONES(in=IN4)
        COMMODITY(in=IN5)
        WTI(in=IN6)
        ;
  by YYYYMMDD ;
  if IN1=1 and IN2=1 and IN3=1 and IN4=1 ;
run ;

data TMP_NEXTDAY ;
  keep LAST_VALUE225
       ;
  set SAMPLE ;

  if _N_=1 then delete ;
run ;

data SAMPLE ;
  keep OBS_DATE
       R_USD
       R_GPB
       R_EUR
       LAST_VALUE225
       LAST_VOLINDEX225
       DOW_JONES_AVERAGE
       COMMODITY_INDEX
       WTI
       NEXT_LAST_VALUE225
       DIFF_NEXT
       DIFF_LAST
       RESULT_WINLOOSE
       ;
  format OBS_DATE
         R_USD
         R_GPB
         R_EUR
         LAST_VALUE225
         LAST_VOLINDEX225
         DOW_JONES_AVERAGE
         COMMODITY_INDEX
         WTI
         NEXT_LAST_VALUE225
         DIFF_NEXT
         DIFF_LAST
         RESULT_WINLOOSE
         ;
  retain TEMP_VAR 0 ;
  merge SAMPLE
        TMP_NEXTDAY(rename=(LAST_VALUE225=NEXT_LAST_VALUE225))
        ;
  OBS_DATE = put(YYYYMMDD, yymmddn8.) ;

  if LAST_VALUE225<NEXT_LAST_VALUE225 then RESULT_WINLOOSE = 'W' ;
  else                                     RESULT_WINLOOSE = 'L' ;

  if NEXT_LAST_VALUE225^=. then do ;
    DIFF_NEXT = NEXT_LAST_VALUE225 - LAST_VALUE225 ;
  end ;
  else DIFF_NEXT = 0 ;
  DIFF_LAST = LAST_VALUE225 - TEMP_VAR ;
  TEMP_VAR = LAST_VALUE225 ;
run ;

proc datasets library=WORK nolist ;
  delete EXCHANGE_RATE
         INDEX_225
         VOLINDEX_225
         DOW_JONES
         COMMODITY
         WTI
         TMP_NEXTDAY
         ;
quit ;

proc corr data=SAMPLE(drop=DIFF_:) noprint out=SAMPLE_CORR ;
run ;

proc transpose data=SAMPLE_CORR out=SAMPLE_CORR_EDIT ;
  var _numeric_ ;
run ;

data _null_ ;
  length VAR_INDEPEND $200
            ;
  retain VAR_INDEPEND
            ;
  set SAMPLE_CORR_EDIT ;
  if NEXT_LAST_VALUE225**2>=0.7 and NEXT_LAST_VALUE225^=1 then do ;
    VAR_INDEPEND = trim(VAR_INDEPEND) || ' ' || trim(_NAME_) ;
    call symput('VAR_INDEPEND', trim(VAR_INDEPEND)) ;
  end ;
run ;

proc datasets library=WORK nolist ;
  delete SAMPLE_CORR_EDIT ;
quit ;

proc reg data=SAMPLE outest=SAMPLE_REG ;
  model NEXT_LAST_VALUE225=&VAR_INDEPEND / noprint ;
quit ;

proc transpose data=SAMPLE_REG out=SAMPLE_REG_EDIT ;
  var _numeric_ ;
run ;

data _null_ ;
  length VAR_REGRESSION $1000
            ;
  retain VAR_REGRESSION
            ;
  set SAMPLE_REG_EDIT ;
  if _NAME_^='_RMSE_' and _NAME_^='NEXT_LAST_VALUE225' then do ;
    if VAR_REGRESSION^='' then do ;
      if _NAME_^='Intercept' then do ;
        VAR_REGRESSION = trim(VAR_REGRESSION) || '+' || '(' || trim(_NAME_) || '*' || compress(put(COL1, 16.10)) || ')' ;
      end ;
      else do ;
        VAR_REGRESSION = trim(VAR_REGRESSION) || '+' || '(' || '&INTERCEPT' || ')' ;
      end ;
    end ;
    else do ;
      if _NAME_^='Intercept' then do ;
        VAR_REGRESSION = '(' || trim(_NAME_) || '*' || compress(put(COL1, 16.10)) || ')' ;
      end ;
      else do ;
        VAR_REGRESSION = '(' || '&INTERCEPT' || ')' ;
      end ;
    end ;
    call symput('VAR_REGRESSION', trim(VAR_REGRESSION)) ;
    if _NAME_='Intercept' then do ;
      call symput('INTERCEPT', compress(put(COL1, 16.10))) ;
    end ;
  end ;
  put VAR_REGRESSION= ;
run ;

proc datasets library=WORK nolist ;
  delete SAMPLE_REG_EDIT
quit ;

filename OUT "&OUT_AREA./sample.csv" ;
run ;

data _null_ ;
  length OBS_DATE_STR $010 ;
  file OUT dlm=',' ;
  set SAMPLE ;
  if _N_=1 then do ;
    put 'OBS_DATE' ','
       'R_USD' ','
       'R_GPB' ','
       'R_EUR' ','
       'LAST_VALUE225' ','
       'LAST_VOLINDEX225' ','
       'DOW_JONES_AVERAGE' ','
       'WTI' ','
       'COMMODITY_INDEX' ','
       'NEXT_LAST_VALUE225' ','
       'DIFF_NEXT' ','
       'DIFF_LAST' ','
       'RESULT_WINLOOSE' ','
       'PREDICT_INDEX225'
       ;
  end ;

  PREDICT_INDEX225 =&VAR_REGRESSION ;

  OBS_DATE_STR = put(input(OBS_DATE, yymmdd8.), yymmdds10.) ;

  put OBS_DATE_STR
      R_USD
      R_GPB
      R_EUR
      LAST_VALUE225
      LAST_VOLINDEX225
      DOW_JONES_AVERAGE
      WTI
      COMMODITY_INDEX
      NEXT_LAST_VALUE225
      DIFF_NEXT
      DIFF_LAST
      RESULT_WINLOOSE
      PREDICT_INDEX225
      ;
run ;
