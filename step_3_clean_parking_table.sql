-- remove all extra spaces from location1, location2, location3, location4 variables in parking table
-- for example 1 COLONEL  SAMUEL SMITH PK DR should be 1 COLONEL SAMUEL SMITH PK DR

-- eliminate apostrophe for future analysis purposes
UPDATE address
SET ward_name = REPLACE(ward_name, '''', '')
WHERE ward_name LIKE '%St. Paul%';

-- 8 rows updated
UPDATE parking_dataset
SET location1 = TRIM(regexp_replace(location1, '\s+', ' ', 'g'))
WHERE location1 LIKE '%  %';

-- 5,471 rows updated
UPDATE parking_dataset
SET location2 = TRIM(regexp_replace(location2, '\s+', ' ', 'g'))
WHERE location2 LIKE '%  %';

-- 0 rows updated
UPDATE parking_dataset
SET location3 = TRIM(regexp_replace(location3, '\s+', ' ', 'g'))
WHERE location3 LIKE '%  %';

-- 103 rows updated
UPDATE parking_dataset
SET location4 = TRIM(regexp_replace(location4, '\s+', ' ', 'g'))
WHERE location4 LIKE '%  %';

-- remove any trailing/ending spaces
UPDATE parking_dataset
SET location1 = RTRIM(location1, ' '),
	location2 = RTRIM(location2, ' '),
	location3 = RTRIM(location3, ' '),
	location4 = RTRIM(location4, ' ');

UPDATE parking_dataset
SET location1 = LTRIM(location1, ' '),
	location2 = LTRIM(location2, ' '),
	location3 = LTRIM(location3, ' '),
	location4 = LTRIM(location4, ' ');

ALTER TABLE parking_dataset
    ADD COLUMN epoch_timestamp bigint,
    ADD COLUMN year int,
    ADD COLUMN month int,
    ADD COLUMN day int,
    ADD COLUMN dayofweek int,
    ADD COLUMN hour int,
    ADD COLUMN thirty_min_int int,
    ADD COLUMN fifteen_min_int int;

UPDATE parking_dataset
SET epoch_timestamp = EXTRACT(EPOCH from date_time_of_infraction),
    year = DATE_PART('year', date_of_infraction),
    month = DATE_PART('month', date_of_infraction),
    day = DATE_PART('day', date_of_infraction),
    dayofweek = EXTRACT(DOW from date_of_infraction),
    hour = EXTRACT(HOUR from date_time_of_infraction),
    thirty_min_int = TRUNC((EXTRACT(MINUTE FROM date_time_of_infraction)/30)+1)*30, 
    fifteen_min_int = TRUNC((EXTRACT(MINUTE FROM date_time_of_infraction)/15)+1)*15;

SELECT date_time_of_infraction, epoch_timestamp, year, month, day, dayofweek, hour, thirty_min_int, fifteen_min_int
FROM parking_dataset 
LIMIT 5;
