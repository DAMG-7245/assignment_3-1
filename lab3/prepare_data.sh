snow sql -q "CREATE OR REPLACE WAREHOUSE NATIVE_APP_QUICKSTART_WH WAREHOUSE_SIZE=SMALL INITIALLY_SUSPENDED=TRUE;

-- this database is used to store our data
CREATE OR REPLACE DATABASE NATIVE_APP_QUICKSTART_DB;
USE DATABASE NATIVE_APP_QUICKSTART_DB;

CREATE OR REPLACE SCHEMA NATIVE_APP_QUICKSTART_SCHEMA;
USE SCHEMA NATIVE_APP_QUICKSTART_SCHEMA;

-- create provider shipping data table
CREATE OR REPLACE TABLE MFG_SHIPPING (
  order_id NUMBER(38,0), 
  ship_order_id NUMBER(38,0),
  status VARCHAR(60),
  lat FLOAT,
  lon FLOAT,
  duration NUMBER(38,0)
);"

# create consumer orders data table
snow sql -q "USE WAREHOUSE NATIVE_APP_QUICKSTART_WH;
-- this database is used to store our data
USE DATABASE NATIVE_APP_QUICKSTART_DB;

USE SCHEMA NATIVE_APP_QUICKSTART_SCHEMA;

CREATE OR REPLACE TABLE MFG_ORDERS (
  order_id NUMBER(38,0), 
  material_name VARCHAR(60),
  supplier_name VARCHAR(60),
  quantity NUMBER(38,0),
  cost FLOAT,
  process_supply_day NUMBER(38,0)
);

-- create consumer recovery data table
CREATE OR REPLACE TABLE MFG_SITE_RECOVERY (
  event_id NUMBER(38,0), 
  recovery_weeks NUMBER(38,0),
  lat FLOAT,
  lon FLOAT
);
"
snow sql -q "
USE DATABASE NATIVE_APP_QUICKSTART_DB;
USE SCHEMA NATIVE_APP_QUICKSTART_SCHEMA;
USE WAREHOUSE NATIVE_APP_QUICKSTART_WH;

--Create named stage
CREATE OR REPLACE STAGE my_stage;
GRANT READ, WRITE ON STAGE my_stage TO ROLE SYSADMIN;


-- Upload files to stage
PUT 'file://D:/Anuj/Second Semester/Big Data VS repo/BigData_Labs/BigData-Assignment3-1/lab3/app/data/shipping_data.csv' @my_stage;

PUT 'file://D:/Anuj/Second Semester/Big Data VS repo/BigData_Labs/BigData-Assignment3-1/lab3/app/data/order_data.csv' @my_stage;

PUT 'file://D:/Anuj/Second Semester/Big Data VS repo/BigData_Labs/BigData-Assignment3-1/lab3/app/data/site_recovery_data.csv' @my_stage;

"

# Step 3: Copy Data from Stage to Tables
snow sql -q "
USE DATABASE NATIVE_APP_QUICKSTART_DB;
USE SCHEMA NATIVE_APP_QUICKSTART_SCHEMA;
USE WAREHOUSE NATIVE_APP_QUICKSTART_WH;

-- Load data from stage to tables
COPY INTO MFG_SHIPPING
FROM @my_stage/shipping_data.csv
FILE_FORMAT = (TYPE = CSV FIELD_OPTIONALLY_ENCLOSED_BY = '\"');

COPY INTO MFG_ORDERS
FROM @my_stage/order_data.csv
FILE_FORMAT = (TYPE = CSV FIELD_OPTIONALLY_ENCLOSED_BY = '\"');

COPY INTO MFG_SITE_RECOVERY
FROM @my_stage/site_recovery_data.csv
FILE_FORMAT = (TYPE = CSV FIELD_OPTIONALLY_ENCLOSED_BY = '\"');
"