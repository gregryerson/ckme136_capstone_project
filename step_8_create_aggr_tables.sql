-- create aggregate table(s) from parking_dataset table
SELECT geo_id, ward_id, ward_name, street_num, match_address, lat, long, year, month, dayofweek, hour, thirty_min_int, fifteen_min_int, COUNT(*) 
INTO parking_dataset_aggr 
FROM parking_dataset 
GROUP BY geo_id, ward_id, ward_name, street_num, match_address, lat, long, year, month, dayofweek, hour, thirty_min_int, fifteen_min_int;

CREATE INDEX idx_pdaggr_geo_id ON parking_dataset_aggr (geo_id);
CREATE INDEX idx_pdaggr_ward_name ON parking_dataset_aggr (ward_name);
CREATE INDEX idx_pdaggr_match_address ON parking_dataset_aggr (match_address, street_num);

-- 17,501,438 records

-- create aggregate table - total parking tickets by address
SELECT geo_id, ward_id, ward_name, street_num, match_address, lat, long, COUNT(*) as count
INTO parking_dataset_aggr_total 
FROM parking_dataset_aggr 
GROUP BY geo_id, ward_id, ward_name, street_num, match_address, lat, long;

CREATE INDEX idx_pdat_geo_id ON parking_dataset_aggr_total (geo_id)

-- 556,461 rows

-- create aggregate table - total parking tickets by address + month
SELECT geo_id, ward_id, ward_name, street_num, match_address, lat, long, month, COUNT(*) as count
INTO parking_dataset_aggr_total_month
FROM parking_dataset_aggr
GROUP BY geo_id, ward_id, ward_name, street_num, match_address, lat, long, month;

CREATE INDEX idx_pdatm_geo_id ON parking_dataset_aggr_total_month (geo_id)
CREATE INDEX idx_pdatm_geo_id_month ON parking_dataset_aggr_total_month (geo_id, month)
CREATE INDEX idx_pdatm_monthON parking_dataset_aggr_total_month (month)

-- 2,374,547 rows

-- create aggregate table - total parking tickets by address + day of week
SELECT geo_id, ward_id, ward_name, street_num, match_address, lat, long, dayofweek, COUNT(*) as count
INTO parking_dataset_aggr_total_dow
FROM parking_dataset_aggr
GROUP BY geo_id, ward_id, ward_name, street_num, match_address, lat, long, dayofweek;

-- 1,810,752 rows

-- create aggregate table - total parking tickets by address + year
SELECT geo_id, ward_id, ward_name, street_num, match_address, lat, long, year, COUNT(*) as count
INTO parking_dataset_aggr_year 
FROM parking_dataset_aggr 
GROUP BY geo_id, ward_id, ward_name, street_num, match_address, lat, long, year;

-- 1,946,084

-- create aggregate table - total parking tickets by address + year + month
SELECT geo_id, ward_id, ward_name, street_num, match_address, lat, long, year, month, COUNT(*) as count
INTO parking_dataset_aggr_year_month 
FROM parking_dataset_aggr 
GROUP BY geo_id, ward_id, ward_name, street_num, match_address, lat, long, year, month;

-- 5,924,441

-- create aggregate table - total parking tickets by address + year + month + dow
SELECT geo_id, ward_id, ward_name, street_num, match_address, lat, long, year, month, dayofweek, COUNT(*) as count
INTO parking_dataset_aggr_year_month_dow 
FROM parking_dataset_aggr 
GROUP BY geo_id, ward_id, ward_name, street_num, match_address, lat, long, year, month, dayofweek;

-- 11,061,261
