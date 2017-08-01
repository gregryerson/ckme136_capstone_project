-- create dataset that includes parking ticket results for each month

CREATE TABLE address_monthly (
municipality varchar(75),
ward_id int,
ward_name varchar(250),
geo_id varchar(50),
addr_num varchar(50),
street_name varchar(50),
feature_code varchar(50),
address_class_descr varchar(250),
geom geometry(Point,4326),
lat float,
long float,
month int);

INSERT INTO address_monthly
SELECT municipality, CAST(SUBSTRING(ward_name FROM '\(([^)]*)\)') as int) as ward_id, ward_name, geo_id, addr_num, street_name, feature_code, address_class_descr, 
geom, lat, long, 1 as month
FROM address;

INSERT INTO address_monthly
SELECT municipality, CAST(SUBSTRING(ward_name FROM '\(([^)]*)\)') as int) as ward_id, ward_name, geo_id, addr_num, street_name, feature_code, address_class_descr, 
geom, lat, long, 2 as month
FROM address;

INSERT INTO address_monthly
SELECT municipality, CAST(SUBSTRING(ward_name FROM '\(([^)]*)\)') as int) as ward_id, ward_name, geo_id, addr_num, street_name, feature_code, address_class_descr, 
geom, lat, long, 3 as month
FROM address;

INSERT INTO address_monthly
SELECT municipality, CAST(SUBSTRING(ward_name FROM '\(([^)]*)\)') as int) as ward_id, ward_name, geo_id, addr_num, street_name, feature_code, address_class_descr,
geom, lat, long, 4 as month
FROM address;

INSERT INTO address_monthly
SELECT municipality, CAST(SUBSTRING(ward_name FROM '\(([^)]*)\)') as int) as ward_id, ward_name, geo_id, addr_num, street_name, feature_code, address_class_descr,
geom, lat, long, 5 as month
FROM address;

INSERT INTO address_monthly
SELECT municipality, CAST(SUBSTRING(ward_name FROM '\(([^)]*)\)') as int) as ward_id, ward_name, geo_id, addr_num, street_name, feature_code, address_class_descr,
geom, lat, long, 6 as month
FROM address;

INSERT INTO address_monthly
SELECT municipality, CAST(SUBSTRING(ward_name FROM '\(([^)]*)\)') as int) as ward_id, ward_name, geo_id, addr_num, street_name, feature_code, address_class_descr,
geom, lat, long, 7 as month
FROM address;

INSERT INTO address_monthly
SELECT municipality, CAST(SUBSTRING(ward_name FROM '\(([^)]*)\)') as int) as ward_id, ward_name, geo_id, addr_num, street_name, feature_code, address_class_descr,
geom, lat, long, 8 as month
FROM address;

INSERT INTO address_monthly
SELECT municipality, CAST(SUBSTRING(ward_name FROM '\(([^)]*)\)') as int) as ward_id, ward_name, geo_id, addr_num, street_name, feature_code, address_class_descr,
geom, lat, long, 9 as month
FROM address;

INSERT INTO address_monthly
SELECT municipality, CAST(SUBSTRING(ward_name FROM '\(([^)]*)\)') as int) as ward_id, ward_name, geo_id, addr_num, street_name, feature_code, address_class_descr,
geom, lat, long, 10 as month
FROM address;

INSERT INTO address_monthly
SELECT municipality, CAST(SUBSTRING(ward_name FROM '\(([^)]*)\)') as int) as ward_id, ward_name, geo_id, addr_num, street_name, feature_code, address_class_descr,
geom, lat, long, 11 as month
FROM address;

INSERT INTO address_monthly
SELECT municipality, CAST(SUBSTRING(ward_name FROM '\(([^)]*)\)') as int) as ward_id, ward_name, geo_id, addr_num, street_name, feature_code, address_class_descr,
geom, lat, long, 12 as month
FROM address;

CREATE INDEX idx_am_geo_id ON address_monthly (geo_id);
CREATE INDEX idx_am_geo_id_month ON address_monthly (geo_id, month);
CREATE INDEX idx_am_month ON address_monthly (month);
CREATE INDEX idx_pdatm_geo_id ON parking_dataset_aggr_total_month (geo_id);
CREATE INDEX idx_pdatm_geo_id_month ON parking_dataset_aggr_total_month (geo_id, month);
CREATE INDEX idx_pdatm_month ON parking_dataset_aggr_total_month (month);

-- add columns 
-- parking tickets - no. of parking tickets by address + month
-- ticketed - if an address has been ticketed TRUE else FALSE
-- has_ticket - dummy variable
-- no_ticket - dummy variable

ALTER TABLE address_monthly
ADD COLUMN parking_tickets int,
ADD COLUMN ticketed boolean,
ADD COLUMN has_ticket boolean,
ADD COLUMN no_ticket boolean;

-- update address_monthly to include parking ticket totals by month
UPDATE address_monthly mon
SET parking_tickets = (CASE WHEN tot.geo_id IS NULL THEN 0 ELSE tot.count END)
FROM parking_dataset_aggr_total_month tot
WHERE mon.geo_id = tot.geo_id
AND mon.month = tot.month;

UPDATE address_monthly 
SET parking_tickets = (CASE WHEN parking_tickets IS NULL THEN 0 ELSE parking_tickets END)
WHERE parking_tickets IS NULL;

-- ticketed - if an address has been ticketed TRUE else FALSE
UPDATE address_monthly 
SET ticketed = (CASE WHEN parking_tickets = 0 THEN FALSE ELSE TRUE END);

UPDATE address_monthly 
SET has_ticket = (CASE WHEN ticketed = TRUE THEN TRUE ELSE FALSE END),
no_ticket = (CASE WHEN ticketed = TRUE THEN FALSE ELSE TRUE END);

-- include the geo_id of the top N ticketed addresses by ward + month to each address within the ward
ALTER TABLE address_monthly
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

CREATE INDEX idx_am_geo_id_1 ON address_monthly (geo_id_1);
CREATE INDEX idx_am_geo_id_2 ON address_monthly (geo_id_2);
CREATE INDEX idx_am_geo_id_3 ON address_monthly (geo_id_3);
CREATE INDEX idx_am_geo_id_4 ON address_monthly (geo_id_4);
CREATE INDEX idx_am_geo_id_5 ON address_monthly (geo_id_5);
CREATE INDEX idx_am_geo_id_6 ON address_monthly (geo_id_6);
CREATE INDEX idx_am_geo_id_7 ON address_monthly (geo_id_7);
CREATE INDEX idx_am_geo_id_8 ON address_monthly (geo_id_8);
CREATE INDEX idx_am_geo_id_9 ON address_monthly (geo_id_9);
CREATE INDEX idx_am_geo_id_10 ON address_monthly (geo_id_10);

-- create ward id column within parking_dataset_aggr_total_month_top_10
ALTER TABLE parking_dataset_aggr_total_month_top_10
ADD COLUMN ward_id int;

UPDATE parking_dataset_aggr_total_month_top_10
SET ward_id = CAST(SUBSTRING(ward_name FROM '\(([^)]*)\)') as int);

CREATE INDEX idx_am_ward_id ON address_monthly (ward_id);

-- update topN ticketed addresses (geo_id) columns by ward + month to each address within the ward
UPDATE address_monthly mon
SET geo_id_1 = top.geo_id
FROM parking_dataset_aggr_total_month_top_10 top
WHERE mon.ward_id = top.ward_id
AND mon.month = top.month
AND top.rank = 1;

UPDATE address_monthly mon
SET geo_id_2 = top.geo_id
FROM parking_dataset_aggr_total_month_top_10 top
WHERE mon.ward_id = top.ward_id
AND mon.month = top.month
AND top.rank = 2;

UPDATE address_monthly mon
SET geo_id_3 = top.geo_id
FROM parking_dataset_aggr_total_month_top_10 top
WHERE mon.ward_id = top.ward_id
AND mon.month = top.month
AND top.rank = 3;

UPDATE address_monthly mon
SET geo_id_4 = top.geo_id
FROM parking_dataset_aggr_total_month_top_10 top
WHERE mon.ward_id = top.ward_id
AND mon.month = top.month
AND top.rank = 4;

UPDATE address_monthly mon
SET geo_id_5 = top.geo_id
FROM parking_dataset_aggr_total_month_top_10 top
WHERE mon.ward_id = top.ward_id
AND mon.month = top.month
AND top.rank = 5;

UPDATE address_monthly mon
SET geo_id_6 = top.geo_id
FROM parking_dataset_aggr_total_month_top_10 top
WHERE mon.ward_id = top.ward_id
AND mon.month = top.month
AND top.rank = 6;

UPDATE address_monthly mon
SET geo_id_7 = top.geo_id
FROM parking_dataset_aggr_total_month_top_10 top
WHERE mon.ward_id = top.ward_id
AND mon.month = top.month
AND top.rank = 7;

UPDATE address_monthly mon
SET geo_id_8 = top.geo_id
FROM parking_dataset_aggr_total_month_top_10 top
WHERE mon.ward_id = top.ward_id
AND mon.month = top.month
AND top.rank = 8;

UPDATE address_monthly mon
SET geo_id_9 = top.geo_id
FROM parking_dataset_aggr_total_month_top_10 top
WHERE mon.ward_id = top.ward_id
AND mon.month = top.month
AND top.rank = 9;

UPDATE address_monthly mon
SET geo_id_10 = top.geo_id
FROM parking_dataset_aggr_total_month_top_10 top
WHERE mon.ward_id = top.ward_id
AND mon.month = top.month
AND top.rank = 10;

-- with geo_id's for topN ticketed addresses by ward, we can obtain the number of tickets by month
-- add lat, long coordinates for each topN geo_id
-- calculate distance between address and topN address

ALTER TABLE address_monthly
ADD COLUMN geo_id_1_tickets bigint,
ADD COLUMN geo_id_1_lat float,
ADD COLUMN geo_id_1_long float,
ADD COLUMN geo_id_1_dist smallint,
ADD COLUMN geo_id_2_tickets bigint,
ADD COLUMN geo_id_2_lat float,
ADD COLUMN geo_id_2_long float,
ADD COLUMN geo_id_2_dist smallint,
ADD COLUMN geo_id_3_tickets bigint,
ADD COLUMN geo_id_3_lat float,
ADD COLUMN geo_id_3_long float,
ADD COLUMN geo_id_3_dist smallint,
ADD COLUMN geo_id_4_tickets bigint,
ADD COLUMN geo_id_4_lat float,
ADD COLUMN geo_id_4_long float,
ADD COLUMN geo_id_4_dist smallint,
ADD COLUMN geo_id_5_tickets bigint,
ADD COLUMN geo_id_5_lat float,
ADD COLUMN geo_id_5_long float,
ADD COLUMN geo_id_5_dist smallint,
ADD COLUMN geo_id_6_tickets bigint,
ADD COLUMN geo_id_6_lat float,
ADD COLUMN geo_id_6_long float,
ADD COLUMN geo_id_6_dist smallint,
ADD COLUMN geo_id_7_tickets bigint,
ADD COLUMN geo_id_7_lat float,
ADD COLUMN geo_id_7_long float,
ADD COLUMN geo_id_7_dist smallint,
ADD COLUMN geo_id_8_tickets bigint,
ADD COLUMN geo_id_8_lat float,
ADD COLUMN geo_id_8_long float,
ADD COLUMN geo_id_8_dist smallint,
ADD COLUMN geo_id_9_tickets bigint,
ADD COLUMN geo_id_9_lat float,
ADD COLUMN geo_id_9_long float,
ADD COLUMN geo_id_9_dist smallint,
ADD COLUMN geo_id_10_tickets bigint,
ADD COLUMN geo_id_10_lat float,
ADD COLUMN geo_id_10_long float,
ADD COLUMN geo_id_10_dist smallint,
ADD COLUMN tickets_nearby bigint;

UPDATE address_monthly mon
SET geo_id_1_tickets = agg.count,
geo_id_1_lat = agg.lat,
geo_id_1_long = agg.long
FROM parking_dataset_aggr_total_month agg
WHERE mon.geo_id_1 = agg.geo_id
AND mon.month = agg.month;

UPDATE address_monthly mon
SET geo_id_2_tickets = agg.count,
geo_id_2_lat = agg.lat,
geo_id_2_long = agg.long
FROM parking_dataset_aggr_total_month agg
WHERE mon.geo_id_2 = agg.geo_id
AND mon.month = agg.month;

UPDATE address_monthly mon
SET geo_id_3_tickets = agg.count,
geo_id_3_lat = agg.lat,
geo_id_3_long = agg.long
FROM parking_dataset_aggr_total_month agg
WHERE mon.geo_id_3 = agg.geo_id
AND mon.month = agg.month;

UPDATE address_monthly mon
SET geo_id_4_tickets = agg.count,
geo_id_4_lat = agg.lat,
geo_id_4_long = agg.long
FROM parking_dataset_aggr_total_month agg
WHERE mon.geo_id_4 = agg.geo_id
AND mon.month = agg.month;

UPDATE address_monthly mon
SET geo_id_5_tickets = agg.count,
geo_id_5_lat = agg.lat,
geo_id_5_long = agg.long
FROM parking_dataset_aggr_total_month agg
WHERE mon.geo_id_5 = agg.geo_id
AND mon.month = agg.month;

UPDATE address_monthly mon
SET geo_id_6_tickets = agg.count,
geo_id_6_lat = agg.lat,
geo_id_6_long = agg.long
FROM parking_dataset_aggr_total_month agg
WHERE mon.geo_id_6 = agg.geo_id
AND mon.month = agg.month;

UPDATE address_monthly mon
SET geo_id_7_tickets = agg.count,
geo_id_7_lat = agg.lat,
geo_id_7_long = agg.long
FROM parking_dataset_aggr_total_month agg
WHERE mon.geo_id_7 = agg.geo_id
AND mon.month = agg.month;

UPDATE address_monthly mon
SET geo_id_8_tickets = agg.count,
geo_id_8_lat = agg.lat,
geo_id_8_long = agg.long
FROM parking_dataset_aggr_total_month agg
WHERE mon.geo_id_8 = agg.geo_id
AND mon.month = agg.month;

UPDATE address_monthly mon
SET geo_id_9_tickets = agg.count,
geo_id_9_lat = agg.lat,
geo_id_9_long = agg.long
FROM parking_dataset_aggr_total_month agg
WHERE mon.geo_id_9 = agg.geo_id
AND mon.month = agg.month;

UPDATE address_monthly mon
SET geo_id_10_tickets = agg.count,
geo_id_10_lat = agg.lat,
geo_id_10_long = agg.long
FROM parking_dataset_aggr_total_month agg
WHERE mon.geo_id_10 = agg.geo_id
AND mon.month = agg.month;

-- calculate distance of address from topN address
UPDATE address_monthly
SET geo_id_1_dist = ROUND((CASE WHEN geo_id_1_lat IS NULL THEN NULL ELSE ST_DISTANCESPHERE(ST_MAKEPOINT(long, lat), ST_MAKEPOINT(geo_id_1_long, geo_id_1_lat)) END)),
	geo_id_2_dist = ROUND((CASE WHEN geo_id_2_lat IS NULL THEN NULL ELSE ST_DISTANCESPHERE(ST_MAKEPOINT(long, lat), ST_MAKEPOINT(geo_id_2_long, geo_id_2_lat)) END)),
	geo_id_3_dist = ROUND((CASE WHEN geo_id_3_lat IS NULL THEN NULL ELSE ST_DISTANCESPHERE(ST_MAKEPOINT(long, lat), ST_MAKEPOINT(geo_id_3_long, geo_id_3_lat)) END)),
	geo_id_4_dist = ROUND((CASE WHEN geo_id_4_lat IS NULL THEN NULL ELSE ST_DISTANCESPHERE(ST_MAKEPOINT(long, lat), ST_MAKEPOINT(geo_id_4_long, geo_id_4_lat)) END)),
	geo_id_5_dist = ROUND((CASE WHEN geo_id_5_lat IS NULL THEN NULL ELSE ST_DISTANCESPHERE(ST_MAKEPOINT(long, lat), ST_MAKEPOINT(geo_id_5_long, geo_id_5_lat)) END)),
	geo_id_6_dist = ROUND((CASE WHEN geo_id_6_lat IS NULL THEN NULL ELSE ST_DISTANCESPHERE(ST_MAKEPOINT(long, lat), ST_MAKEPOINT(geo_id_6_long, geo_id_6_lat)) END)),
	geo_id_7_dist = ROUND((CASE WHEN geo_id_7_lat IS NULL THEN NULL ELSE ST_DISTANCESPHERE(ST_MAKEPOINT(long, lat), ST_MAKEPOINT(geo_id_7_long, geo_id_7_lat)) END)),
	geo_id_8_dist = ROUND((CASE WHEN geo_id_8_lat IS NULL THEN NULL ELSE ST_DISTANCESPHERE(ST_MAKEPOINT(long, lat), ST_MAKEPOINT(geo_id_8_long, geo_id_8_lat)) END)),
	geo_id_9_dist = ROUND((CASE WHEN geo_id_9_lat IS NULL THEN NULL ELSE ST_DISTANCESPHERE(ST_MAKEPOINT(long, lat), ST_MAKEPOINT(geo_id_9_long, geo_id_9_lat)) END)),
	geo_id_10_dist = ROUND((CASE WHEN geo_id_10_lat IS NULL THEN NULL ELSE ST_DISTANCESPHERE(ST_MAKEPOINT(long, lat), ST_MAKEPOINT(geo_id_10_long, geo_id_10_lat)) END));

-- calculate tickets nearby for each address
-- if an address is within 500 metres of a tonN address, then include number of tickets
UPDATE address_monthly
SET tickets_nearby = (CASE WHEN geo_id_1_dist <= 500 THEN geo_id_1_tickets ELSE 0 END)
					+(CASE WHEN geo_id_2_dist <= 500 THEN geo_id_2_tickets ELSE 0 END)
					+(CASE WHEN geo_id_3_dist <= 500 THEN geo_id_3_tickets ELSE 0 END)
					+(CASE WHEN geo_id_4_dist <= 500 THEN geo_id_4_tickets ELSE 0 END)
					+(CASE WHEN geo_id_5_dist <= 500 THEN geo_id_5_tickets ELSE 0 END)
					+(CASE WHEN geo_id_6_dist <= 500 THEN geo_id_6_tickets ELSE 0 END)
					+(CASE WHEN geo_id_7_dist <= 500 THEN geo_id_7_tickets ELSE 0 END)
					+(CASE WHEN geo_id_8_dist <= 500 THEN geo_id_8_tickets ELSE 0 END)
					+(CASE WHEN geo_id_9_dist <= 500 THEN geo_id_9_tickets ELSE 0 END);

-- create table which includes 

SELECT *, RANK() OVER (PARTITION geo_id, month ORDER BY parking_tickets DESC) as parking_ticket_rank
INTO address_monthly_rank 
FROM address_monthly;

ALTER TABLE address_monthly_rank
ADD COLUMN season varchar(25);

UPDATE address_monthly_rank
SET season = (CASE WHEN month IN (1, 2, 12) THEN 'Winter'
			  WHEN month IN (3, 4, 5) THEN 'Spring'
			  WHEN month IN (6, 7, 8) THEN 'Summer'
			  WHEN month IN (9, 10, 11) THEN 'Fall' ELSE NULL END);
