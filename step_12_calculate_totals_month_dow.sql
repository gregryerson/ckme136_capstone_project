SELECT ward_id, ward_name, geo_id, street_num, match_address, lat, long, month, dayofweek, SUM(count) as parking_tickets
INTO parking_dataset_aggr_total_month_dow
FROM parking_dataset_aggr
GROUP BY ward_name, geo_id, street_num, match_address, lat, long, month, dayofweek;

CREATE INDEX idx_pdatmd_geo_id ON parking_dataset_aggr_total_month_dow (geo_id);
CREATE INDEX idx_pdatmd_geo_id_month ON parking_dataset_aggr_total_month_dow (geo_id, month);
CREATE INDEX idx_pdatmd_month ON parking_dataset_aggr_total_month_dow (month);
CREATE INDEX idx_pdatmd_dow ON parking_dataset_aggr_total_month_dow (dayofweek);


# 5,816,076 rows

# find 10 most ticketed addresses by ward name + month + dayofweek
SELECT ward_id, ward_name, geo_id, street_num, match_address, lat, long, month, dayofweek, parking_tickets, pos as rank
INTO parking_dataset_aggr_total_month_dow_top_10
FROM (SELECT geo_id, ward_id, ward_name, street_num, match_address, lat, long, month, dayofweek, parking_tickets,
			 RANK() OVER (PARTITION BY ward_id, ward_name, month, dayofweek ORDER BY parking_tickets DESC) as pos 
			 FROM parking_dataset_aggr_total_month_dow) AS ss
WHERE pos <= 10;

CREATE INDEX idx_pdatmd_top_geo_id ON parking_dataset_aggr_total_month_dow_top_10 (geo_id);
CREATE INDEX idx_pdatmd_top_ward_name ON parking_dataset_aggr_total_month_dow_top_10 (ward_name);
CREATE INDEX idx_pdatmd_top_month ON parking_dataset_aggr_total_month_dow_top_10 (month);
CREATE INDEX idx_pdatmd_top_dow ON parking_dataset_aggr_total_month_dow_top_10 (dayofweek);

# 39,119 rows

ALTER TABLE parking_dataset_aggr_total_month_dow_top_10
ADD COLUMN perc_of_ward float, 
ADD COLUMN cum_perc_of_ward float; 

UPDATE parking_dataset_aggr_total_month_dow_top_10 top
SET perc_of_ward = top.parking_tickets / src.total
FROM (SELECT ward_name, month, dayofweek, SUM(parking_tickets) as total 
	  FROM parking_dataset_aggr_total_month_dow
	  GROUP BY ward_name, month, dayofweek) as src
WHERE top.ward_name = src.ward_name
AND top.month = src.month
AND top.dayofweek = src.dayofweek;

# 38,268 rows updated