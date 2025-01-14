create or replace database METROPT2;

use database METROPT2;
use schema PUBLIC;

create or replace stage FROM_LP36131
    directory = (enable = true)
    encryption = ( type = 'snowflake_sse')
;

-- snowSQL:  
-- use warehouse COMPUTZE_WH;
-- use database METROPT2;
-- use schema PUBLIC;
-- put file:/c:/Users/balzer/Documents/Projekte/Sulzer/DMAS/10.DMAS.Materialien/MetroPT2_predictive_maintenance/7766691.zip @FROM_LP36131;

list @DMAS.METROPT2.FROM_LP36131;

-- Laden der Dateien !

select metadata$filename, count(*) from @FROM_LP36131 group by 1;
select $1 from @FROM_LP36131/dataset_train.csv.gz limit 100;

create or replace file format PT2_FORMAT_ANALOG
    type = csv,
    compression = gzip
    --record_delimiter = nl
    field_delimiter = ','
    parse_header = true
    --skip_header = 1
    timestamp_format = 'YYYY-MM-DD HH24:MI:SS'
;

select *
    from table(infer_schema(
                   location => '@FROM_LP36131',
                   file_format => 'PT2_FORMAT_ANALOG'
               ) 
         )
;

select 
        $1			as TS
        --$1:TP2				        as TP2
        --$1:TP3				        as TP3,
        --$1:H1				        as H1,
        --$1:DV_pressure				as DV_PRESSURE,
        --$1:Reservoirs				as RESERVOIRS,
        --$1:Oil_temperature			as OIL_TEMPERATURE,
        --$1:Flowmeter				as FLOWMETER,
        --$1:Motor_current			as MOTOR_CURRENT,
        --$1:COMP				        as COMP,
        --$1:DV_eletric				as DV_ELETRIC,
        --$1:Towers				    as TOWERS,
        --$1:MPG				        as MPG,
        --$1:LPS				        as LPS,
        --$1:Pressure_switch			as PRESSURE_SWITCH,
        --$1:Oil_level				as OIL_LEVEL,
        --$1:Caudal_impulses			as CAUDAL_IMPULSES,
        --$1:gpsLong				    as GPSLONG,
        --$1:gpsLat				    as GPSLAT,
        --$1:gpsSpeed				as GPSSPEED,
        --$1:gpsQuality				as GPSQUALITY

   from @DMAS.METROPT2.FROM_LP36131/dataset_train.csv.gz
        (file_format => DMAS.METROPT2.PT2_FORMAT_ANALOG)
   limit 10
;



-- Colum-Hilfen    ------------------------------------------------------------------------
-- select upper('timestamp,TP2,TP3,H1,DV_pressure,Reservoirs,Oil_temperature,Flowmeter,Motor_current,COMP,DV_eletric,Towers,MPG,LPS,Pressure_switch,Oil_level,Caudal_impulses,gpsLong,gpsLat,gpsSpeed,gpsQuality') as STRG;

-- select x.value||' as '||upper(x.value)||',' as COL from table(split_to_table('timestamp,TP2,TP3,H1,DV_pressure,Reservoirs,Oil_temperature,Flowmeter,Motor_current,COMP,DV_eletric,Towers,MPG,LPS,Pressure_switch,Oil_level,Caudal_impulses,gpsLong,gpsLat,gpsSpeed,gpsQuality', ',')) as x;


-- =====================================================================================================
-- Analog (dataset_train)

create or replace file format PT2_FORMAT_ANALOG
    type = csv,
    compression = gzip
    --record_delimiter = nl
    field_delimiter = ','
    parse_header = true
    --skip_header = 1
    timestamp_format = 'YYYY-MM-DD HH24:MI:SS'
;

create or replace table DMAS.METROPT2.DATASET_TRAIN (
    TIMESTAMP					TIMESTAMP_NTZ,
    TP2					        NUMBER(18, 16),
    TP3					        NUMBER(18, 16),
    H1					        NUMBER(18, 16),
    DV_PRESSURE					NUMBER(17, 16),
    RESERVOIRS					TEXT,
    OIL_TEMPERATURE				NUMBER(17, 15),
    FLOWMETER					NUMBER(17, 15),
    MOTOR_CURRENT				NUMBER(17, 16),
    COMP					    NUMBER(2, 1),
    DV_ELETRIC					NUMBER(2, 1),
    TOWERS					    NUMBER(2, 1),
    MPG					        NUMBER(2, 1),
    LPS					        NUMBER(2, 1),
    PRESSURE_SWITCH				NUMBER(2, 1),
    OIL_LEVEL					NUMBER(2, 1),
    CAUDAL_IMPULSES				NUMBER(2, 1),
    GPSLAT					    NUMBER(8, 6),
    GPSLONG					    NUMBER(7, 6),
    GPSSPEED					NUMBER(4, 1),
    GPSQUALITY					NUMBER(2, 1)
);
copy into DMAS.METROPT2.DATASET_TRAIN
     from @DMAS.METROPT2.FROM_LP36131
     files = ('dataset_train.csv.gz')
     file_format = (format_name = 'DMAS.METROPT2.PT2_FORMAT_ANALOG')
     match_by_column_name = case_insensitive
;

-- =====================================================================================================
-- Digital (metroPT2)

create or replace table DMAS.METROPT2.DATASET_METROPT2(
    TIMESTAMP					TIMESTAMP_NTZ,
    TP2					        NUMBER(18, 16),
    TP3					        NUMBER(18, 16),
    H1					        NUMBER(18, 16),
    DV_PRESSURE					NUMBER(17, 16),
    RESERVOIRS					TEXT,
    OIL_TEMPERATURE				NUMBER(17, 15),
    FLOWMETER					NUMBER(17, 15),
    MOTOR_CURRENT				NUMBER(17, 16),
    COMP					    NUMBER(2, 1),
    DV_ELETRIC					NUMBER(2, 1),
    TOWERS					    NUMBER(2, 1),
    MPG					        NUMBER(2, 1),
    LPS					        NUMBER(2, 1),
    PRESSURE_SWITCH				NUMBER(2, 1),
    OIL_LEVEL					NUMBER(2, 1),
    CAUDAL_IMPULSES				NUMBER(2, 1),
    GPSLAT					    NUMBER(8, 6),
    GPSLONG					    NUMBER(7, 6),
    GPSSPEED					NUMBER(4, 1),
    GPSQUALITY					NUMBER(2, 1)
);

create or replace file format PT2_FORMAT_DIGITAL
    type = csv,
    compression = gzip
    --record_delimiter = nl
    field_delimiter = ','
    parse_header = true
    --skip_header = 1
    timestamp_format = 'YYYY-MM-DD HH24:MI:SS.FF3'
;

-- -----------------------------------------------------------------
create warehouse LOAD_PT2_M
    warehouse_type = standard
    warehouse_size = medium
    auto_suspend =30
    auto_resume = false
    initially_suspended = true
;
alter warehouse COMPUTE_WH suspend;
use warehouse LOAD_PT2_M;
alter warehouse LOAD_PT2_M resume;

copy into DMAS.METROPT2.DATASET_METROPT2
     from @DMAS.METROPT2.FROM_LP36131
     files = ('metroPT2.csv.gz')
     file_format = (format_name = 'DMAS.METROPT2.PT2_FORMAT_DIGITAL')
     match_by_column_name = case_insensitive
;

alter warehouse LOAD_PT2_M suspend;
