-- aggregate parking_dataset for addresses and obtain gps coordinates from address table
SELECT  location1, location2, location3, location4, SUM(count) as count, loc1_has_num, loc1_starts_w_num, loc1_has_letter, loc2_has_num, loc2_starts_w_num, loc2_has_letter, 
loc3_has_num, loc3_starts_w_num, loc3_has_letter, loc4_has_num, loc4_starts_w_num, loc4_has_letter, clean_address, street_num, street_name, street_type, street_dir, 
street_name_clean, match_address, clean_intersection, int1_clean_address, int1_street_name_clean, int1_street_type, int1_street_dir, int1_match_address, int2_clean_address, 
int2_street_name_clean, int2_street_type, int2_street_dir, int2_match_address, match_intersection
INTO parking_ticket_address
FROM parking_dataset
GROUP BY location1, location2, location3, location4, loc1_has_num, loc1_starts_w_num, loc1_has_letter, loc2_has_num, loc2_starts_w_num, loc2_has_letter, loc3_has_num, 
loc3_starts_w_num, loc3_has_letter, loc4_has_num, loc4_starts_w_num, loc4_has_letter, clean_address, street_num, street_name, street_type, street_dir, street_name_clean, 
match_address, clean_intersection, int1_clean_address, int1_street_name_clean, int1_street_type, int1_street_dir, int1_match_address, int2_clean_address, 
int2_street_name_clean, int2_street_type, int2_street_dir, int2_match_address, match_intersection;

-- update address to match address case within address table
UPDATE parking_ticket_address
SET match_address = INITCAP(match_address);

ALTER TABLE parking_ticket_address
ADD COLUMN geo_id varchar(50),
ADD COLUMN lat float,
ADD COLUMN long float,
ADD COLUMN municipality varchar(50),
ADD COLUMN ward_id int,
ADD COLUMN ward_name varchar(50);

CREATE INDEX idx_pta_match_address ON parking_ticket_address (match_address, street_num);
CREATE INDEX idx_pta_match_intersection ON parking_ticket_address (match_intersection);

UPDATE parking_ticket_address prk
SET long = add.long,
lat = add.lat,
geo_id = add.geo_id
FROM address add
WHERE add.addr_num = prk.street_num
AND add.street_name = INITCAP(prk.match_address)
AND prk.clean_intersection IS NULL;

-- 605,389 rows updated

UPDATE parking_ticket_address add
SET municipality = geo.municipality_revised,
ward_id = geo.ward_id,
ward_name = geo.ward_name
FROM geo_id geo
WHERE add.geo_id = geo.geo_id;

-- 605,389 rows updated

CREATE INDEX idx_pta_ward_id ON parking_ticket_address (ward_id);
CREATE INDEX idx_pta_geo_id ON parking_ticket_address (geo_id);



-- run step_6_parking_tickets_address_gps_coordinates to include find gps coordinates for addresses that were not matched during the join

