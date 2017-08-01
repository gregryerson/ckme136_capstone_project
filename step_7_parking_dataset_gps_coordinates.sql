-- update gps coordinates parking_dataset with resutlts from gps  
UPDATE parking_dataset prk
SET long = add.long,
	lat = add.lat,
	geo_id = add.geo_id,
    municipality = add.municipality,
    ward_id = add.ward_id,
    ward_name = add.ward_name
FROM parking_ticket_address add
WHERE add.street_num = prk.street_num
AND add.match_address = prk.match_address
AND prk.clean_intersection IS NULL;

-- 21,994,149 rows updated

UPDATE parking_dataset prk
SET long = add.long,
	lat = add.lat,
	geo_id = add.geo_id
FROM parking_ticket_address add
WHERE add.int1_match_address = prk.int1_match_address
AND add.int2_match_address = prk.int2_match_address
AND prk.clean_intersection IS NOT NULL;

-- 1,126,089 rows updated

-- in total, there are 22,252,987 records that can be used for analysis, 
-- total records : 23,192,489
-- nearly 96% (0.9597) of dataset can be used 
-- SELECT COUNT(*) FROM parking_dataset WHERE lat IS NOT NULL;
-- SELECT COUNT(*) FROM parking_dataset;

-- add season/weekend variables

ALTER TABLE parking_dataset_aggr 
ADD COLUMN season varchar(25),
ADD COLUMN weekend boolean;

UPDATE parking_dataset_aggr
SET season = (CASE WHEN month IN (1, 2, 12) THEN 'Winter'
			  WHEN month IN (3, 4, 5) THEN 'Spring'
			  WHEN month IN (6, 7, 8) THEN 'Summer'
			  WHEN month IN (9, 10, 11) THEN 'Fall' ELSE 'Other' END),
	weekend = (CASE WHEN dayofweek IN (0, 6) THEN TRUE ELSE FALSE END);
