-- find 10 most ticketed addresses by ward name overall
SELECT geo_id, ward_name, street_num, match_address, lat, long, count
INTO parking_dataset_aggr_total_top_10
FROM (SELECT geo_id, ward_name, street_num, match_address, lat, long, count,
			 rank() OVER (PARTITION BY ward_name ORDER BY count DESC) as pos 
			 FROM parking_dataset_aggr_total) AS ss
WHERE pos <= 10;

CREATE INDEX idx_pdat_top_geo_id ON parking_dataset_aggr_total_top_10 (geo_id);
CREATE INDEX idx_pdat_top_ward_name ON parking_dataset_aggr_total_top_10 (ward_name);

-- 450 rows

-- find 10 most ticketed addresses by ward name + month
SELECT geo_id, ward_name, street_num, match_address, month, lat, long, count
INTO parking_dataset_aggr_total_month_top_10
FROM (SELECT geo_id, ward_name, street_num, match_address, month, lat, long, count,
			 rank() OVER (PARTITION BY ward_name, month ORDER BY count DESC) as pos 
			 FROM parking_dataset_aggr_total_month) AS ss
WHERE pos <= 10;

-- 5,461 rows

CREATE INDEX idx_pdat_month_top_geo_id ON parking_dataset_aggr_total_month_top_10 (geo_id);
CREATE INDEX idx_pdat_month_top_ward_name ON parking_dataset_aggr_total_month_top_10 (ward_name);

-- find 10 most ticketed addresses by ward name + day of week
SELECT geo_id, ward_name, street_num, match_address, dayofweek, lat, long, count
INTO parking_dataset_aggr_total_dow_top_10
FROM (SELECT geo_id, ward_name, street_num, match_address, dayofweek, lat, long, count,
			 rank() OVER (PARTITION BY ward_name,dayofweek ORDER BY count DESC) as pos 
			 FROM parking_dataset_aggr_total_dow) AS ss
WHERE pos <= 10;

CREATE INDEX idx_pdat_dow_top_geo_id ON parking_dataset_aggr_total_month_top_10 (geo_id);
CREATE INDEX idx_pdat_dow_top_ward_name ON parking_dataset_aggr_total_month_top_10 (ward_name);

-- 3,177 rows

-- find 10 most ticketed addresses by ward name + year
SELECT geo_id, ward_name, street_num, match_address, lat, long, year, count
INTO parking_dataset_aggr_year_top_10
FROM (SELECT geo_id, ward_name, street_num, match_address, lat, long, year, count,
			 rank() OVER (PARTITION BY ward_name, year ORDER BY count DESC) as pos 
			 FROM parking_dataset_aggr_year) AS ss
WHERE pos <= 10;

CREATE INDEX idx_pdaty_top_geo_id ON parking_dataset_aggr_year_top_10 (geo_id);
CREATE INDEX idx_pdaty_top_ward_name ON parking_dataset_aggr_year_top_10 (ward_name);

-- 4,083 rows

-- find 10 most ticketed addresses by ward name + year + month
SELECT geo_id, ward_name, street_num, match_address, lat, long, year, month, count
INTO parking_dataset_aggr_year_month_top_10
FROM (SELECT geo_id, ward_name, street_num, match_address, lat, long, year, month, count,
			 rank() OVER (PARTITION BY ward_name, year, month ORDER BY count DESC) as pos 
			 FROM parking_dataset_aggr_year_month) AS ss
WHERE pos <= 10;

CREATE INDEX idx_pdatym_top_geo_id ON parking_dataset_aggr_year_month_top_10 (geo_id);
CREATE INDEX idx_pdatym_top_ward_name ON parking_dataset_aggr_year_month_top_10 (ward_name);

-- 53,489 rows

-- find 10 most ticketed addresses by ward name + year + month + day of week
SELECT geo_id, ward_name, street_num, match_address, lat, long, year, month, dayofweek, count
INTO parking_dataset_aggr_year_month_dow_top_10
FROM (SELECT geo_id, ward_name, street_num, match_address, lat, long, year, month, dayofweek, count,
			 rank() OVER (PARTITION BY ward_name, year, month, dayofweek ORDER BY count DESC) as pos 
			 FROM parking_dataset_aggr_year_month_dow) AS ss
WHERE pos <= 10;

CREATE INDEX idx_pdatymd_top_geo_id ON parking_dataset_aggr_year_month_dow_top_10 (geo_id);
CREATE INDEX idx_pdatymd_top_ward_name ON parking_dataset_aggr_year_month_dow_top_10 (ward_name);

-- 816,667 rows

-- calculate the percentage of tickets each address represents for its respective ward
-- obtain rank of each address ticketed by ward name
-- overall

ALTER TABLE parking_dataset_aggr_total_top_10
ADD COLUMN perc_of_ward float, 
ADD COLUMN cum_perc_of_ward float, 
ADD COLUMN rank int;

UPDATE parking_dataset_aggr_total_top_10 top
SET perc_of_ward = top.count / src.total
FROM (SELECT ward_name, SUM(count) as total 
	  FROM parking_dataset_aggr_total_top_10
	  GROUP BY ward_name) as src
WHERE top.ward_name = src.ward_name;

---- 440 rows updated

UPDATE parking_dataset_aggr_total_top_10 top
SET cum_perc_of_ward = src.cum_per
FROM (SELECT geo_id, ward_name, perc_of_ward, 
	  SUM(perc_of_ward) OVER (PARTITION BY ward_name ORDER BY count DESC) as cum_per
	  FROM parking_dataset_aggr_total_top_10) as src
WHERE top.geo_id = src.geo_id 
AND top.ward_name = src.ward_name;

---- 440 rows updated

UPDATE parking_dataset_aggr_total_top_10 top
SET rank = src.rank
FROM (SELECT geo_id, ward_name, count,
	  ROW_NUMBER() OVER (PARTITION BY ward_name ORDER BY count DESC) as rank
	  FROM parking_dataset_aggr_total_top_10) as src
WHERE top.geo_id = src.geo_id 
AND top.ward_name = src.ward_name;

CREATE INDEX dx_pdat_top_rank ON parking_dataset_aggr_total_top_10 (rank)

---- 440 rows updated

-- calculate the percentage of tickets each address represents for its respective ward
-- obtain rank of each address ticketed by ward name
-- by month

ALTER TABLE parking_dataset_aggr_total_month_top_10
ADD COLUMN perc_of_ward float, 
ADD COLUMN cum_perc_of_ward float, 
ADD COLUMN rank int;

UPDATE parking_dataset_aggr_total_month_top_10 top
SET perc_of_ward = top.count / src.total
FROM (SELECT ward_name, month, SUM(count) as total 
	  FROM parking_dataset_aggr_total_month_top_10
	  GROUP BY ward_name, month) as src
WHERE top.ward_name = src.ward_name
AND top.month = src.month;

---- 5,341 rows updated

UPDATE parking_dataset_aggr_total_month_top_10 top
SET cum_perc_of_ward = src.cum_per
FROM (SELECT geo_id, ward_name, month, perc_of_ward, 
	  SUM(perc_of_ward) OVER (PARTITION BY ward_name, month ORDER BY count DESC) as cum_per
	  FROM parking_dataset_aggr_total_month_top_10) as src
WHERE top.geo_id = src.geo_id 
AND top.ward_name = src.ward_name
AND top.month = src.month;

---- 5,341 rows updated

UPDATE parking_dataset_aggr_total_month_top_10 top
SET rank = src.rank
FROM (SELECT geo_id, ward_name, month, count,
	  ROW_NUMBER() OVER (PARTITION BY ward_name, month ORDER BY count DESC) as rank
	  FROM parking_dataset_aggr_total_month_top_10) as src
WHERE top.geo_id = src.geo_id 
AND top.ward_name = src.ward_name
AND top.month = src.month;

CREATE INDEX dx_pdat_month_top_rank ON parking_dataset_aggr_total_top_10 (rank);

---- 5,341 rows updated

-- calculate the percentage of tickets each address represents for its respective ward
-- obtain rank of each address ticketed by ward name
-- by day of week

ALTER TABLE parking_dataset_aggr_total_dow_top_10
ADD COLUMN perc_of_ward float, 
ADD COLUMN cum_perc_of_ward float, 
ADD COLUMN rank int;

UPDATE parking_dataset_aggr_total_dow_top_10 top
SET perc_of_ward = top.count / src.total
FROM (SELECT ward_name, dayofweek, SUM(count) as total 
	  FROM parking_dataset_aggr_total_dow_top_10
	  GROUP BY ward_name, dayofweek) as src
WHERE top.ward_name = src.ward_name
AND top.dayofweek = src.dayofweek;

---- 3,107 rows updated

UPDATE parking_dataset_aggr_total_dow_top_10 top
SET cum_perc_of_ward = src.cum_per
FROM (SELECT geo_id, ward_name, dayofweek, perc_of_ward, 
	  SUM(perc_of_ward) OVER (PARTITION BY ward_name, dayofweek ORDER BY count DESC) as cum_per
	  FROM parking_dataset_aggr_total_dow_top_10) as src
WHERE top.geo_id = src.geo_id 
AND top.ward_name = src.ward_name
AND top.dayofweek = src.dayofweek;

---- 3,107 rows updated

UPDATE parking_dataset_aggr_total_dow_top_10 top
SET rank = src.rank
FROM (SELECT geo_id, ward_name, dayofweek, count,
	  ROW_NUMBER() OVER (PARTITION BY ward_name, dayofweek ORDER BY count DESC) as rank
	  FROM parking_dataset_aggr_total_dow_top_10) as src
WHERE top.geo_id = src.geo_id 
AND top.ward_name = src.ward_name
AND top.dayofweek = src.dayofweek;

CREATE INDEX dx_pdat_dow_top_rank ON parking_dataset_aggr_total_top_10 (rank);

---- 3,107 rows updated

-- calculate the percentage of tickets each address represents for its respective ward
-- obtain rank of each address ticketed by ward name
-- by year

ALTER TABLE parking_dataset_aggr_year_top_10
ADD COLUMN perc_of_ward float, 
ADD COLUMN cum_perc_of_ward float, 
ADD COLUMN rank int;

UPDATE parking_dataset_aggr_year_top_10 top
SET perc_of_ward = top.count / src.total
FROM (SELECT ward_name, year, SUM(count) as total 
	  FROM parking_dataset_aggr_year_top_10
	  GROUP BY ward_name, year) as src
WHERE top.ward_name = src.ward_name
AND top.year = src.year;

---- 3,992 rows updated

UPDATE parking_dataset_aggr_year_top_10 top
SET cum_perc_of_ward = src.cum_per
FROM (SELECT geo_id, ward_name, year, perc_of_ward, 
	  SUM(perc_of_ward) OVER (PARTITION BY ward_name, year ORDER BY count DESC) as cum_per
	  FROM parking_dataset_aggr_year_top_10) as src
WHERE top.geo_id = src.geo_id 
AND top.ward_name = src.ward_name
AND top.year = src.year;

---- 3,992 rows updated

UPDATE parking_dataset_aggr_year_top_10 top
SET rank = src.rank
FROM (SELECT geo_id, ward_name, year, count,
	  ROW_NUMBER() OVER (PARTITION BY ward_name, year ORDER BY count DESC) as rank
	  FROM parking_dataset_aggr_year_top_10) as src
WHERE top.geo_id = src.geo_id 
AND top.ward_name = src.ward_name
AND top.year = src.year;

---- 3,992 rows updated
