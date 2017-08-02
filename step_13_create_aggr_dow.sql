CREATE TABLE address_dow (
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
dayofweek int,
weekend boolean);

INSERT INTO address_dow
SELECT municipality, ward_id, ward_name, geo_id, addr_num, street_name, feature_code, address_class_descr, lat, long, 0 as dayofweek, TRUE as weekend
FROM address;

INSERT INTO address_dow
SELECT municipality, ward_id, ward_name, geo_id, addr_num, street_name, feature_code, address_class_descr, lat, long, 1 as dayofweek, FALSE as weekend
FROM address;

INSERT INTO address_dow
SELECT municipality, ward_id, ward_name, geo_id, addr_num, street_name, feature_code, address_class_descr, lat, long, 2 as dayofweek, FALSE as weekend
FROM address;

INSERT INTO address_dow
SELECT municipality, ward_id, ward_name, geo_id, addr_num, street_name, feature_code, address_class_descr, lat, long, 3 as dayofweek, FALSE as weekend
FROM address;

INSERT INTO address_dow
SELECT municipality, ward_id, ward_name, geo_id, addr_num, street_name, feature_code, address_class_descr, lat, long, 4 as dayofweek, FALSE as weekend
FROM address;

INSERT INTO address_dow
SELECT municipality, ward_id, ward_name, geo_id, addr_num, street_name, feature_code, address_class_descr, lat, long, 5 as dayofweek, FALSE as weekend
FROM address;

INSERT INTO address_dow
SELECT municipality, ward_id, ward_name, geo_id, addr_num, street_name, feature_code, address_class_descr, lat, long, 6 as dayofweek, TRUE as weekend
FROM address;

CREATE INDEX idx_ad_dow ON address_dow (dayofweek);
CREATE INDEX idx_ad_dow_geo_id ON address_dow (geo_id);
CREATE INDEX idx_ad_geo_id ON address_dow (geo_id);

-- add columns 
-- parking tickets - no. of parking tickets by address + month
-- ticketed - if an address has been ticketed TRUE else FALSE

ALTER TABLE address_dow
ADD COLUMN parking_tickets int,
ADD COLUMN ticketed boolean;

# update address_dow to include parking ticket totals by month
UPDATE address_dow dow
SET parking_tickets = (CASE WHEN tot.geo_id IS NULL THEN 0 ELSE tot.count END)
FROM parking_dataset_aggr_total_dow tot
WHERE dow.geo_id = tot.geo_id
AND dow.dayofweek = tot.dayofweek;

UPDATE address_dow
SET parking_tickets = 0 
WHERE parking_tickets IS NULL;

UPDATE address_dow
SET ticketed = (CASE WHEN parking_tickets > 0 THEN TRUE ELSE FALSE END);

# create new table that includes parking ticket rank by ward_id, dow
SELECT *, RANK() OVER(PARTITION BY ward_id, dayofweek ORDER BY parking_tickets DESC) as parking_ticket_rank
INTO address_dow_rank
FROM address_dow;

CREATE INDEX idx_adr_dow ON address_dow_rank (dayofweek);
CREATE INDEX idx_adr_dow_geo_id ON address_dow_rank (geo_id);
CREATE INDEX idx_adr_geo_id ON address_dow_rank (geo_id);
