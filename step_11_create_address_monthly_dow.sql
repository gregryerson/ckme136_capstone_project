-- create dataset that includes parking ticket results for each month

SELECT geo_id, ward_id, ward_name, street_num, match_address, month, dayofweek, lat, long, count as parking_tickets, pos as rank
INTO parking_dataset_aggr_total_month_dayofweek_top_10
FROM (SELECT CAST(SUBSTRING(ward_name FROM '\(([^)]*)\)') as int) as ward_id, ward_name, geo_id, street_num, match_address, lat, dayofweek, long, month, count,
			 ROW_NUMBER() OVER (PARTITION BY CAST(SUBSTRING(ward_name FROM '\(([^)]*)\)') as int), ward_name, month, dayofweek ORDER BY count DESC) as pos 
			 FROM parking_dataset_aggr) AS ss
WHERE pos <= 10;

--37,800 rows

ALTER TABLE parking_dataset_aggr_total_month_dayofweek_top_10
ADD COLUMN row_id varchar(255);

UPDATE parking_dataset_aggr_total_month_dayofweek_top_10
SET row_id = ward_id || '_' || month || '_' || dayofweek;

CREATE INDEX idx_pdatmdow_top_geo_id ON parking_dataset_aggr_total_month_dayofweek_top_10 (geo_id);
CREATE INDEX idx_pdatmdow_top_ward_name ON parking_dataset_aggr_total_month_dayofweek_top_10 (ward_name);
CREATE INDEX idx_pdatmdow_row_id ON parking_dataset_aggr_total_month_dow_top_10 (row_id);


CREATE TABLE address_monthly_dow (
municipality varchar(75),
ward_id int,
ward_name varchar(250),
geo_id varchar(50),
addr_num varchar(50),
street_name varchar(50),
feature_code varchar(50),
address_class_descr varchar(250),
lat float,
long float,
month int,
dayofweek int);

INSERT INTO address_monthly_dow
SELECT municipality, ward_id, ward_name, geo_id, addr_num, street_name, feature_code, address_class_descr, lat, long, 
1 as month, 0 as dayofweek
FROM address;

INSERT INTO address_monthly_dow
SELECT municipality, ward_id, ward_name, geo_id, addr_num, street_name, feature_code, address_class_descr, lat, long, 
1 as month, 1 as dayofweek
FROM address;

INSERT INTO address_monthly_dow
SELECT municipality, ward_id, ward_name, geo_id, addr_num, street_name, feature_code, address_class_descr, lat, long, 
1 as month, 2 as dayofweek
FROM address;

INSERT INTO address_monthly_dow
SELECT municipality, ward_id, ward_name, geo_id, addr_num, street_name, feature_code, address_class_descr, lat, long, 
1 as month, 3 as dayofweek
FROM address;

INSERT INTO address_monthly_dow
SELECT municipality, ward_id, ward_name, geo_id, addr_num, street_name, feature_code, address_class_descr, lat, long, 
1 as month, 4 as dayofweek
FROM address;

INSERT INTO address_monthly_dow
SELECT municipality, ward_id, ward_name, geo_id, addr_num, street_name, feature_code, address_class_descr, lat, long, 
1 as month, 5 as dayofweek
FROM address;

INSERT INTO address_monthly_dow
SELECT municipality, ward_id, ward_name, geo_id, addr_num, street_name, feature_code, address_class_descr, lat, long, 
1 as month, 6 as dayofweek
FROM address;

INSERT INTO address_monthly_dow
SELECT municipality, ward_id, ward_name, geo_id, addr_num, street_name, feature_code, address_class_descr, lat, long, 
2 as month, 0 as dayofweek
FROM address;

INSERT INTO address_monthly_dow
SELECT municipality, ward_id, ward_name, geo_id, addr_num, street_name, feature_code, address_class_descr, lat, long, 
2 as month, 1 as dayofweek
FROM address;

INSERT INTO address_monthly_dow
SELECT municipality, ward_id, ward_name, geo_id, addr_num, street_name, feature_code, address_class_descr, lat, long, 
2 as month, 2 as dayofweek
FROM address;

INSERT INTO address_monthly_dow
SELECT municipality, ward_id, ward_name, geo_id, addr_num, street_name, feature_code, address_class_descr, lat, long, 
2 as month, 3 as dayofweek
FROM address;

INSERT INTO address_monthly_dow
SELECT municipality, ward_id, ward_name, geo_id, addr_num, street_name, feature_code, address_class_descr, lat, long, 
2 as month, 4 as dayofweek
FROM address;

INSERT INTO address_monthly_dow
SELECT municipality, ward_id, ward_name, geo_id, addr_num, street_name, feature_code, address_class_descr, lat, long, 
2 as month, 5 as dayofweek
FROM address;

INSERT INTO address_monthly_dow
SELECT municipality, ward_id, ward_name, geo_id, addr_num, street_name, feature_code, address_class_descr, lat, long, 
2 as month, 6 as dayofweek
FROM address;

INSERT INTO address_monthly_dow
SELECT municipality, ward_id, ward_name, geo_id, addr_num, street_name, feature_code, address_class_descr, lat, long, 
3 as month, 0 as dayofweek
FROM address;

INSERT INTO address_monthly_dow
SELECT municipality, ward_id, ward_name, geo_id, addr_num, street_name, feature_code, address_class_descr, lat, long, 
3 as month, 1 as dayofweek
FROM address;

INSERT INTO address_monthly_dow
SELECT municipality, ward_id, ward_name, geo_id, addr_num, street_name, feature_code, address_class_descr, lat, long, 
3 as month, 2 as dayofweek
FROM address;

INSERT INTO address_monthly_dow
SELECT municipality, ward_id, ward_name, geo_id, addr_num, street_name, feature_code, address_class_descr, lat, long, 
3 as month, 3 as dayofweek
FROM address;

INSERT INTO address_monthly_dow
SELECT municipality, ward_id, ward_name, geo_id, addr_num, street_name, feature_code, address_class_descr, lat, long, 
3 as month, 4 as dayofweek
FROM address;

INSERT INTO address_monthly_dow
SELECT municipality, ward_id, ward_name, geo_id, addr_num, street_name, feature_code, address_class_descr, lat, long, 
3 as month, 5 as dayofweek
FROM address;

INSERT INTO address_monthly_dow
SELECT municipality, ward_id, ward_name, geo_id, addr_num, street_name, feature_code, address_class_descr, lat, long, 
3 as month, 6 as dayofweek
FROM address;

INSERT INTO address_monthly_dow
SELECT municipality, ward_id, ward_name, geo_id, addr_num, street_name, feature_code, address_class_descr, lat, long, 
4 as month, 0 as dayofweek
FROM address;

INSERT INTO address_monthly_dow
SELECT municipality, ward_id, ward_name, geo_id, addr_num, street_name, feature_code, address_class_descr, lat, long, 
4 as month, 1 as dayofweek
FROM address;

INSERT INTO address_monthly_dow
SELECT municipality, ward_id, ward_name, geo_id, addr_num, street_name, feature_code, address_class_descr, lat, long, 
4 as month, 2 as dayofweek
FROM address;

INSERT INTO address_monthly_dow
SELECT municipality, ward_id, ward_name, geo_id, addr_num, street_name, feature_code, address_class_descr, lat, long, 
4 as month, 3 as dayofweek
FROM address;

INSERT INTO address_monthly_dow
SELECT municipality, ward_id, ward_name, geo_id, addr_num, street_name, feature_code, address_class_descr, lat, long, 
4 as month, 4 as dayofweek
FROM address;

INSERT INTO address_monthly_dow
SELECT municipality, ward_id, ward_name, geo_id, addr_num, street_name, feature_code, address_class_descr, lat, long, 
4 as month, 5 as dayofweek
FROM address;

INSERT INTO address_monthly_dow
SELECT municipality, ward_id, ward_name, geo_id, addr_num, street_name, feature_code, address_class_descr, lat, long, 
4 as month, 6 as dayofweek
FROM address;

INSERT INTO address_monthly_dow
SELECT municipality, ward_id, ward_name, geo_id, addr_num, street_name, feature_code, address_class_descr, lat, long, 
5 as month, 0 as dayofweek
FROM address;

INSERT INTO address_monthly_dow
SELECT municipality, ward_id, ward_name, geo_id, addr_num, street_name, feature_code, address_class_descr, lat, long, 
5 as month, 1 as dayofweek
FROM address;

INSERT INTO address_monthly_dow
SELECT municipality, ward_id, ward_name, geo_id, addr_num, street_name, feature_code, address_class_descr, lat, long, 
5 as month, 2 as dayofweek
FROM address;

INSERT INTO address_monthly_dow
SELECT municipality, ward_id, ward_name, geo_id, addr_num, street_name, feature_code, address_class_descr, lat, long, 
5 as month, 3 as dayofweek
FROM address;

INSERT INTO address_monthly_dow
SELECT municipality, ward_id, ward_name, geo_id, addr_num, street_name, feature_code, address_class_descr, lat, long, 
5 as month, 4 as dayofweek
FROM address;

INSERT INTO address_monthly_dow
SELECT municipality, ward_id, ward_name, geo_id, addr_num, street_name, feature_code, address_class_descr, lat, long, 
5 as month, 5 as dayofweek
FROM address;

INSERT INTO address_monthly_dow
SELECT municipality, ward_id, ward_name, geo_id, addr_num, street_name, feature_code, address_class_descr, lat, long, 
5 as month, 6 as dayofweek
FROM address;

INSERT INTO address_monthly_dow
SELECT municipality, ward_id, ward_name, geo_id, addr_num, street_name, feature_code, address_class_descr, lat, long, 
6 as month, 0 as dayofweek
FROM address;

INSERT INTO address_monthly_dow
SELECT municipality, ward_id, ward_name, geo_id, addr_num, street_name, feature_code, address_class_descr, lat, long, 
6 as month, 1 as dayofweek
FROM address;

INSERT INTO address_monthly_dow
SELECT municipality, ward_id, ward_name, geo_id, addr_num, street_name, feature_code, address_class_descr, lat, long, 
6 as month, 2 as dayofweek
FROM address;

INSERT INTO address_monthly_dow
SELECT municipality, ward_id, ward_name, geo_id, addr_num, street_name, feature_code, address_class_descr, lat, long, 
6 as month, 3 as dayofweek
FROM address;

INSERT INTO address_monthly_dow
SELECT municipality, ward_id, ward_name, geo_id, addr_num, street_name, feature_code, address_class_descr, lat, long, 
6 as month, 4 as dayofweek
FROM address;

INSERT INTO address_monthly_dow
SELECT municipality, ward_id, ward_name, geo_id, addr_num, street_name, feature_code, address_class_descr, lat, long, 
6 as month, 5 as dayofweek
FROM address;

INSERT INTO address_monthly_dow
SELECT municipality, ward_id, ward_name, geo_id, addr_num, street_name, feature_code, address_class_descr, lat, long, 
6 as month, 6 as dayofweek
FROM address;

INSERT INTO address_monthly_dow
SELECT municipality,  ward_id, ward_name, geo_id, addr_num, street_name, feature_code, address_class_descr, lat, long, 
7 as month, 0 as dayofweek
FROM address;

INSERT INTO address_monthly_dow
SELECT municipality, ward_id, ward_name, geo_id, addr_num, street_name, feature_code, address_class_descr, lat, long, 
7 as month, 1 as dayofweek
FROM address;

INSERT INTO address_monthly_dow
SELECT municipality, ward_id, ward_name, geo_id, addr_num, street_name, feature_code, address_class_descr, lat, long, 
7 as month, 2 as dayofweek
FROM address;

INSERT INTO address_monthly_dow
SELECT municipality, ward_id, ward_name, geo_id, addr_num, street_name, feature_code, address_class_descr, lat, long, 
7 as month, 3 as dayofweek
FROM address;

INSERT INTO address_monthly_dow
SELECT municipality,  ward_id, ward_name, geo_id, addr_num, street_name, feature_code, address_class_descr, lat, long, 
7 as month, 4 as dayofweek
FROM address;

INSERT INTO address_monthly_dow
SELECT municipality, ward_id, ward_name, geo_id, addr_num, street_name, feature_code, address_class_descr, lat, long, 
7 as month, 5 as dayofweek
FROM address;

INSERT INTO address_monthly_dow
SELECT municipality, ward_id, ward_name, geo_id, addr_num, street_name, feature_code, address_class_descr, lat, long, 
7 as month, 6 as dayofweek
FROM address;

INSERT INTO address_monthly_dow
SELECT municipality, ward_id, ward_name, geo_id, addr_num, street_name, feature_code, address_class_descr, lat, long, 
8 as month, 0 as dayofweek
FROM address;

INSERT INTO address_monthly_dow
SELECT municipality, ward_id, ward_name, geo_id, addr_num, street_name, feature_code, address_class_descr, lat, long, 
8 as month, 1 as dayofweek
FROM address;

INSERT INTO address_monthly_dow
SELECT municipality, ward_id, ward_name, geo_id, addr_num, street_name, feature_code, address_class_descr, lat, long, 
8 as month, 2 as dayofweek
FROM address;

INSERT INTO address_monthly_dow
SELECT municipality, ward_id, ward_name, geo_id, addr_num, street_name, feature_code, address_class_descr, lat, long, 
8 as month, 3 as dayofweek
FROM address;

INSERT INTO address_monthly_dow
SELECT municipality, ward_id, ward_name, geo_id, addr_num, street_name, feature_code, address_class_descr, lat, long, 
8 as month, 4 as dayofweek
FROM address;

INSERT INTO address_monthly_dow
SELECT municipality, ward_id, ward_name, geo_id, addr_num, street_name, feature_code, address_class_descr, lat, long, 
8 as month, 5 as dayofweek
FROM address;

INSERT INTO address_monthly_dow
SELECT municipality, ward_id, ward_name, geo_id, addr_num, street_name, feature_code, address_class_descr, lat, long, 
8 as month, 6 as dayofweek
FROM address;

INSERT INTO address_monthly_dow
SELECT municipality, ward_id, ward_name, geo_id, addr_num, street_name, feature_code, address_class_descr, lat, long, 
9 as month, 0 as dayofweek
FROM address;

INSERT INTO address_monthly_dow
SELECT municipality, ward_id, ward_name, geo_id, addr_num, street_name, feature_code, address_class_descr, lat, long, 
9 as month, 1 as dayofweek
FROM address;

INSERT INTO address_monthly_dow
SELECT municipality, ward_id, ward_name, geo_id, addr_num, street_name, feature_code, address_class_descr, lat, long, 
9 as month, 2 as dayofweek
FROM address;

INSERT INTO address_monthly_dow
SELECT municipality, ward_id, ward_name, geo_id, addr_num, street_name, feature_code, address_class_descr, lat, long, 
9 as month, 3 as dayofweek
FROM address;

INSERT INTO address_monthly_dow
SELECT municipality, ward_id, ward_name, geo_id, addr_num, street_name, feature_code, address_class_descr, lat, long, 
9 as month, 4 as dayofweek
FROM address;

INSERT INTO address_monthly_dow
SELECT municipality, ward_id, ward_name, geo_id, addr_num, street_name, feature_code, address_class_descr, lat, long, 
9 as month, 5 as dayofweek
FROM address;

INSERT INTO address_monthly_dow
SELECT municipality, ward_id, ward_name, geo_id, addr_num, street_name, feature_code, address_class_descr, lat, long, 
9 as month, 6 as dayofweek
FROM address;

INSERT INTO address_monthly_dow
SELECT municipality, ward_id, ward_name, geo_id, addr_num, street_name, feature_code, address_class_descr, lat, long, 
10 as month, 0 as dayofweek
FROM address;

INSERT INTO address_monthly_dow
SELECT municipality, ward_id, ward_name, geo_id, addr_num, street_name, feature_code, address_class_descr, lat, long, 
10 as month, 1 as dayofweek
FROM address;

INSERT INTO address_monthly_dow
SELECT municipality, ward_id, ward_name, geo_id, addr_num, street_name, feature_code, address_class_descr, lat, long, 
10 as month, 2 as dayofweek
FROM address;

INSERT INTO address_monthly_dow
SELECT municipality, ward_id, ward_name, geo_id, addr_num, street_name, feature_code, address_class_descr, lat, long, 
10 as month, 3 as dayofweek
FROM address;

INSERT INTO address_monthly_dow
SELECT municipality, ward_id, ward_name, geo_id, addr_num, street_name, feature_code, address_class_descr, lat, long, 
10 as month, 4 as dayofweek
FROM address;

INSERT INTO address_monthly_dow
SELECT municipality, ward_id, ward_name, geo_id, addr_num, street_name, feature_code, address_class_descr, lat, long, 
10 as month, 5 as dayofweek
FROM address;

INSERT INTO address_monthly_dow
SELECT municipality, ward_id, ward_name, geo_id, addr_num, street_name, feature_code, address_class_descr, lat, long, 
10 as month, 6 as dayofweek
FROM address;

INSERT INTO address_monthly_dow
SELECT municipality, ward_id, ward_name, geo_id, addr_num, street_name, feature_code, address_class_descr, lat, long, 
11 as month, 0 as dayofweek
FROM address;

INSERT INTO address_monthly_dow
SELECT municipality, ward_id, ward_name, geo_id, addr_num, street_name, feature_code, address_class_descr, lat, long, 
11 as month, 1 as dayofweek
FROM address;

INSERT INTO address_monthly_dow
SELECT municipality, ward_id, ward_name, geo_id, addr_num, street_name, feature_code, address_class_descr, lat, long, 
11 as month, 2 as dayofweek
FROM address;

INSERT INTO address_monthly_dow
SELECT municipality, ward_id, ward_name, geo_id, addr_num, street_name, feature_code, address_class_descr, lat, long, 
11 as month, 3 as dayofweek
FROM address;

INSERT INTO address_monthly_dow
SELECT municipality, ward_id, ward_name, geo_id, addr_num, street_name, feature_code, address_class_descr, lat, long, 
11 as month, 4 as dayofweek
FROM address;

INSERT INTO address_monthly_dow
SELECT municipality, ward_id, ward_name, geo_id, addr_num, street_name, feature_code, address_class_descr, lat, long, 
11 as month, 5 as dayofweek
FROM address;

INSERT INTO address_monthly_dow
SELECT municipality, ward_id, ward_name, geo_id, addr_num, street_name, feature_code, address_class_descr, lat, long, 
11 as month, 6 as dayofweek
FROM address;

INSERT INTO address_monthly_dow
SELECT municipality, ward_id, ward_name, geo_id, addr_num, street_name, feature_code, address_class_descr, lat, long, 
12 as month, 0 as dayofweek
FROM address;

INSERT INTO address_monthly_dow
SELECT municipality, ward_id, ward_name, geo_id, addr_num, street_name, feature_code, address_class_descr, lat, long, 
12 as month, 1 as dayofweek
FROM address;

INSERT INTO address_monthly_dow
SELECT municipality, ward_id, ward_name, geo_id, addr_num, street_name, feature_code, address_class_descr, lat, long, 
12 as month, 2 as dayofweek
FROM address;

INSERT INTO address_monthly_dow
SELECT municipality, ward_id, ward_name, geo_id, addr_num, street_name, feature_code, address_class_descr, lat, long, 
12 as month, 3 as dayofweek
FROM address;

INSERT INTO address_monthly_dow
SELECT municipality, ward_id, ward_name, geo_id, addr_num, street_name, feature_code, address_class_descr, lat, long, 
12 as month, 4 as dayofweek
FROM address;

INSERT INTO address_monthly_dow
SELECT municipality, ward_id, ward_name, geo_id, addr_num, street_name, feature_code, address_class_descr, lat, long, 
12 as month, 5 as dayofweek
FROM address;

INSERT INTO address_monthly_dow
SELECT municipality, ward_id, ward_name, geo_id, addr_num, street_name, feature_code, address_class_descr, lat, long, 
12 as month, 6 as dayofweek
FROM address;

CREATE INDEX idx_amd_geo_id ON address_monthly_dow (geo_id);
CREATE INDEX idx_amd_geo_id_month ON address_monthly_dow (geo_id, month);
CREATE INDEX idx_amd_geo_id_month_dow ON address_monthly_dow (geo_id, month, dayofweek);
CREATE INDEX idx_amd_month ON address_monthly_dow (month);
CREATE INDEX idx_amd_month_dow ON address_monthly_dow (month, dayofweek);
CREATE INDEX idx_amd_dow ON address_monthly_dow (dayofweek);

-- add columns 
-- parking tickets - no. of parking tickets by address + month
-- ticketed - if an address has been ticketed TRUE else FALSE
-- has_ticket - dummy variable
-- no_ticket - dummy variable
ALTER TABLE address_monthly_dow
ADD COLUMN parking_tickets int,
ADD COLUMN ticketed boolean;

-- update address_monthly to include parking ticket totals by month
UPDATE address_monthly_dow dow
SET parking_tickets = (CASE WHEN tot.geo_id IS NULL THEN 0 ELSE tot.parking_tickets END)
FROM parking_dataset_aggr_total_month_dow tot
WHERE dow.geo_id = tot.geo_id
AND dow.month = tot.month
AND dow.dayofweek = tot.dayofweek;

UPDATE address_monthly_dow
SET parking_tickets = (CASE WHEN parking_tickets IS NULL THEN 0 ELSE parking_tickets END)
WHERE parking_tickets IS NULL;

-- include the geo_id of the top N ticketed addresses by ward + month to each address within the ward
ALTER TABLE address_monthly_dow
ADD COLUMN geo_id_1 int,
ADD COLUMN geo_id_2 int,
ADD COLUMN geo_id_3 int,
ADD COLUMN geo_id_4 int,
ADD COLUMN geo_id_5 int,
ADD COLUMN geo_id_6 int,
ADD COLUMN geo_id_7 int,
ADD COLUMN geo_id_8 int,
ADD COLUMN geo_id_9 int,
ADD COLUMN geo_id_10 int;

CREATE INDEX idx_amd_geo_id_1 ON address_monthly_dow (geo_id_1);
CREATE INDEX idx_amd_geo_id_2 ON address_monthly_dow (geo_id_2);
CREATE INDEX idx_amd_geo_id_3 ON address_monthly_dow (geo_id_3);
CREATE INDEX idx_amd_geo_id_4 ON address_monthly_dow (geo_id_4);
CREATE INDEX idx_amd_geo_id_5 ON address_monthly_dow (geo_id_5);
CREATE INDEX idx_amd_geo_id_6 ON address_monthly_dow (geo_id_6);
CREATE INDEX idx_amd_geo_id_7 ON address_monthly_dow (geo_id_7);
CREATE INDEX idx_amd_geo_id_8 ON address_monthly_dow (geo_id_8);
CREATE INDEX idx_amd_geo_id_9 ON address_monthly_dow (geo_id_9);
CREATE INDEX idx_amd_geo_id_10 ON address_monthly_dow (geo_id_10);

-- create ward id column within parking_dataset_aggr_total_month_top_10
CREATE INDEX idx_amd_ward_id ON address_monthly_dow (ward_id);

-- update topN ticketed addresses (geo_id) columns by ward + month+ dayofweek to each address within the ward
ALTER TABLE address_monthly_dow
ADD COLUMN row_id varchar(255);

UPDATE address_monthly_dow
SET row_id = ward_id || '_' || month || '_' || dayofweek;

CREATE INDEX idx_amd_row_id ON address_monthly_dow (row_id);

ALTER TABLE parking_dataset_aggr_total_month_dow_top_10
ADD COLUMN row_id varchar(255);

UPDATE parking_dataset_aggr_total_month_dow_top_10
SET row_id = ward_id || '_' || month || '_' || dayofweek;

CREATE INDEX idx_pdatmd_row_id ON parking_dataset_aggr_total_month_dow_top_10 (row_id);

UPDATE address_monthly_dow dow
SET geo_id_1 = CAST(top.geo_id as int)
FROM parking_dataset_aggr_total_month_dayofweek_top_10 top
WHERE dow.ward_id = top.ward_id
AND dow.month = top.month
AND dow.dayofweek = top.dayofweek
AND top.rank = 1;

-- 43,943,844 rows updated

UPDATE address_monthly_dow dow
SET geo_id_2 = CAST(top.geo_id as int)
FROM parking_dataset_aggr_total_month_dayofweek_top_10 top
WHERE dow.ward_id = top.ward_id
AND dow.month = top.month
AND dow.dayofweek = top.dayofweek
AND top.rank = 2;

-- 43,943,844 rows updated

UPDATE address_monthly_dow dow
SET geo_id_3 = CAST(top.geo_id as int)
FROM parking_dataset_aggr_total_month_dayofweek_top_10 top
WHERE dow.ward_id = top.ward_id
AND dow.month = top.month
AND dow.dayofweek = top.dayofweek
AND top.rank = 3;

-- 43,943,844 rows updated

UPDATE address_monthly_dow dow
SET geo_id_4 = CAST(top.geo_id as int)
FROM parking_dataset_aggr_total_month_dow_top_10 top
WHERE dow.ward_id = top.ward_id
AND dow.month = top.month
AND dow.dayofweek = top.dayofweek
AND top.rank = 4;

-- 41,135,112 rows updated

UPDATE address_monthly_dow dow
SET geo_id_5 = CAST(top.geo_id as int)
FROM parking_dataset_aggr_total_month_dayofweek_top_10 top
WHERE dow.ward_id = top.ward_id
AND dow.month = top.month
AND dow.dayofweek = top.dayofweek
AND top.rank = 5;

-- 43,943,844 rows updated

UPDATE address_monthly_dow dow
SET geo_id_6 = CAST(top.geo_id as int)
FROM parking_dataset_aggr_total_month_dayofweek_top_10 top
WHERE dow.ward_id = top.ward_id
AND dow.month = top.month
AND dow.dayofweek = top.dayofweek
AND top.rank = 6;

-- 43,943,844 rows updated

UPDATE address_monthly_dow dow
SET geo_id_7 = CAST(top.geo_id as int)
FROM parking_dataset_aggr_total_month_dow_top_10 top
WHERE dow.ward_id = top.ward_id
AND dow.month = top.month
AND dow.dayofweek = top.dayofweek
AND top.rank = 7;

-- 37,477,556 rows updated

UPDATE address_monthly_dow dow
SET geo_id_8 = CAST(top.geo_id as int)
FROM parking_dataset_aggr_total_month_dow_top_10 top
WHERE dow.ward_id = top.ward_id
AND dow.month = top.month
AND dow.dayofweek = top.dayofweek
AND top.rank = 8;

-- 36,693,562 rows updated

UPDATE address_monthly_dow dow
SET geo_id_9 = CAST(top.geo_id as int)
FROM parking_dataset_aggr_total_month_dow_top_10 top
WHERE dow.ward_id = top.ward_id
AND dow.month = top.month
AND dow.dayofweek = top.dayofweek
AND top.rank = 9;

-- 35,122,559 rows updated

UPDATE address_monthly_dow dow
SET geo_id_10 = CAST(top.geo_id as int)
FROM parking_dataset_aggr_total_month_dow_top_10 top
WHERE dow.ward_id = top.ward_id
AND dow.month = top.month
AND dow.dayofweek = top.dayofweek
AND top.rank = 10;

-- 33,695,124 rows updated

-- with geo_id's for topN ticketed addresses by ward, we can obtain the number of tickets by month + dow
-- add lat, long coordinates for each topN geo_id
-- calculate distance between address and topN address

ALTER TABLE address_monthly_dow
ADD COLUMN geo_id_1_tickets int,
ADD COLUMN geo_id_1_lat float,
ADD COLUMN geo_id_1_long float,
ADD COLUMN geo_id_1_dist smallint,
ADD COLUMN geo_id_2_tickets int,
ADD COLUMN geo_id_2_lat float,
ADD COLUMN geo_id_2_long float,
ADD COLUMN geo_id_2_dist smallint,
ADD COLUMN geo_id_3_tickets int,
ADD COLUMN geo_id_3_lat float,
ADD COLUMN geo_id_3_long float,
ADD COLUMN geo_id_3_dist smallint,
ADD COLUMN geo_id_4_tickets int,
ADD COLUMN geo_id_4_lat float,
ADD COLUMN geo_id_4_long float,
ADD COLUMN geo_id_4_dist smallint,
ADD COLUMN geo_id_5_tickets int,
ADD COLUMN geo_id_5_lat float,
ADD COLUMN geo_id_5_long float,
ADD COLUMN geo_id_5_dist smallint,
ADD COLUMN geo_id_6_tickets int,
ADD COLUMN geo_id_6_lat float,
ADD COLUMN geo_id_6_long float,
ADD COLUMN geo_id_6_dist smallint,
ADD COLUMN geo_id_7_tickets int,
ADD COLUMN geo_id_7_lat float,
ADD COLUMN geo_id_7_long float,
ADD COLUMN geo_id_7_dist smallint,
ADD COLUMN geo_id_8_tickets int,
ADD COLUMN geo_id_8_lat float,
ADD COLUMN geo_id_8_long float,
ADD COLUMN geo_id_8_dist smallint,
ADD COLUMN geo_id_9_tickets int,
ADD COLUMN geo_id_9_lat float,
ADD COLUMN geo_id_9_long float,
ADD COLUMN geo_id_9_dist smallint,
ADD COLUMN geo_id_10_tickets int,
ADD COLUMN geo_id_10_lat float,
ADD COLUMN geo_id_10_long float,
ADD COLUMN geo_id_10_dist smallint,
ADD COLUMN tickets_nearby int;

UPDATE address_monthly_dow dow
SET geo_id_1_tickets = agg.parking_tickets,
geo_id_1_lat = agg.lat,
geo_id_1_long = agg.long
FROM parking_dataset_aggr_total_month_dow agg
WHERE dow.geo_id_1 = agg.geo_id
AND dow.month = agg.month
AND dow.dayofweek = agg.dayofweek;

-- 43,943,844 rows updated

UPDATE address_monthly_dow dow
SET geo_id_2_tickets = agg.parking_tickets,
geo_id_2_lat = agg.lat,
geo_id_2_long = agg.long
FROM parking_dataset_aggr_total_month_dow agg
WHERE dow.geo_id_2 = agg.geo_id
AND dow.month = agg.month
AND dow.dayofweek = agg.dayofweek;

-- 43,943,844 rows updated

UPDATE address_monthly_dow dow
SET geo_id_3_tickets = agg.parking_tickets,
geo_id_3_lat = agg.lat,
geo_id_3_long = agg.long
FROM parking_dataset_aggr_total_month_dow agg
WHERE dow.geo_id_3 = agg.geo_id
AND dow.month = agg.month
AND dow.dayofweek = agg.dayofweek;

UPDATE address_monthly_dow dow
SET geo_id_4_tickets = agg.parking_tickets,
geo_id_4_lat = agg.lat,
geo_id_4_long = agg.long
FROM parking_dataset_aggr_total_month_dow agg
WHERE dow.geo_id_4 = agg.geo_id
AND dow.month = agg.month
AND dow.dayofweek = agg.dayofweek;


SELECT *, 
RANK() OVER (PARTITION BY ward_name, month, dayofweek ORDER BY parking_tickets DESC) as parking_ticket_rank 
INTO address_monthly_dow_rank 
FROM address_monthly_dow;

ALTER TABLE address_monthly_dow_rank 
ADD COLUMN season varchar(25),
ADD COLUMN weekend boolean;
 
UPDATE address_monthly_dow_rank
SET season = (CASE WHEN month IN (1, 2, 12) THEN 'Winter'
			  WHEN month IN (3, 4, 5) THEN 'Spring'
			  WHEN month IN (6, 7, 8) THEN 'Summer'
			  WHEN month IN (9, 10, 11) THEN 'Fall' ELSE 'Other' END),
	weekend = (CASE WHEN dayofweek IN (0, 6) THEN TRUE ELSE FALSE END);

UPDATE address_monthly_dow_rank
SET ticketed = (CASE WHEN parking_tickets > 0 THEN TRUE ELSE FALSE END);

