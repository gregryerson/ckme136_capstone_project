-- is there a difference in distance between a popular ticketed address / versus non-popular / an address that is not ticketed at all

SELECT *, RANK() OVER (PARTITION BY ward_name, month ORDER BY parking_tickets DESC) as parking_ticket_rank 
INTO address_monthly_rank
FROM address_monthly

CREATE INDEX idx_amr_geo_id ON address_monthly_rank (geo_id);
CREATE INDEX idx_amr_geo_id_month ON address_monthly_rank (geo_id, month);
CREATE INDEX idx_amr_month ON address_monthly_rank (month);

ALTER TABLE address_monthly_rank
ADD COLUMN parking_ticket_rank_10 int,
ADD COLUMN parking_ticket_rank_25 int,
ADD COLUMN parking_ticket_rank_50 int;

UPDATE address_monthly_rank
SET parking_ticket_rank_10 = (CASE WHEN parking_ticket_rank <= 10 THEN 10
							  WHEN parking_ticket_rank > 10 AND parking_tickets > 0 THEN 1
							  WHEN parking_tickets = 0 THEN 0
							  ELSE 0 END),
	parking_ticket_rank_25 = (CASE WHEN parking_ticket_rank <= 25 THEN 25
							  WHEN parking_ticket_rank > 25 AND parking_tickets > 0 THEN 1
							  WHEN parking_tickets = 0 THEN 0
							  ELSE 0 END),
	parking_ticket_rank_50 = (CASE WHEN parking_ticket_rank <= 50 THEN 50
							  WHEN parking_ticket_rank > 50 AND parking_tickets > 0 THEN 1
							  WHEN parking_tickets = 0 THEN 0
							  ELSE 0 END);


SELECT ward_id, ward_name, parking_ticket_rank_10, COUNT(*) as num_addresses, 
SUM(parking_tickets) as total_parking_tickets, ROUND(AVG(parking_tickets)) as avg_parking_tickets, 
SUM(tickets_nearby) as total_tickets_nearby, ROUND(AVG(tickets_nearby)) as avg_tickets_nearby, 
ROUND(AVG(geo_id_1_dist)) as gid_1_dist, ROUND(AVG(geo_id_1_tickets)) as gid_1_tckts, ROUND(AVG(geo_id_2_dist)) as gid_2_dist, ROUND(AVG(geo_id_2_tickets)) as gid_2_tckts, 
ROUND(AVG(geo_id_3_dist)) as gid_3_dist, ROUND(AVG(geo_id_3_tickets)) as gid_3_tckts, ROUND(AVG(geo_id_4_dist)) as gid_4_dist, ROUND(AVG(geo_id_4_tickets)) as gid_4_tckts,
ROUND(AVG(geo_id_5_dist)) as gid_5_dist, ROUND(AVG(geo_id_5_tickets)) as gid_5_tckts, ROUND(AVG(geo_id_6_dist)) as gid_6_dist, ROUND(AVG(geo_id_6_tickets)) as gid_6_tckts, 
ROUND(AVG(geo_id_7_dist)) as gid_7_dist, ROUND(AVG(geo_id_7_tickets)) as gid_7_tckts, ROUND(AVG(geo_id_8_dist)) as gid_8_dist, ROUND(AVG(geo_id_8_tickets)) as gid_8_tckts, 
ROUND(AVG(geo_id_9_dist)) as gid_9_dist, ROUND(AVG(geo_id_9_tickets)) as gid_9_tckts, ROUND(AVG(geo_id_10_dist)) as gid_10_dist, ROUND(AVG(geo_id_10_tickets)) as gid_10_tckts
INTO ward_avg_distance_top10
FROM address_monthly_rank
GROUP BY ward_id, ward_name, parking_ticket_rank_10
ORDER BY ward_id, parking_ticket_rank_10;

SELECT ward_id, ward_name, parking_ticket_rank_25, COUNT(*) as num_addresses, 
SUM(parking_tickets) as total_parking_tickets, ROUND(AVG(parking_tickets)) as avg_parking_tickets, 
SUM(tickets_nearby) as total_tickets_nearby, ROUND(AVG(tickets_nearby)) as avg_tickets_nearby, 
ROUND(AVG(geo_id_1_dist)) as gid_1_dist, ROUND(AVG(geo_id_1_tickets)) as gid_1_tckts, ROUND(AVG(geo_id_2_dist)) as gid_2_dist, ROUND(AVG(geo_id_2_tickets)) as gid_2_tckts, 
ROUND(AVG(geo_id_3_dist)) as gid_3_dist, ROUND(AVG(geo_id_3_tickets)) as gid_3_tckts, ROUND(AVG(geo_id_4_dist)) as gid_4_dist, ROUND(AVG(geo_id_4_tickets)) as gid_4_tckts,
ROUND(AVG(geo_id_5_dist)) as gid_5_dist, ROUND(AVG(geo_id_5_tickets)) as gid_5_tckts, ROUND(AVG(geo_id_6_dist)) as gid_6_dist, ROUND(AVG(geo_id_6_tickets)) as gid_6_tckts, 
ROUND(AVG(geo_id_7_dist)) as gid_7_dist, ROUND(AVG(geo_id_7_tickets)) as gid_7_tckts, ROUND(AVG(geo_id_8_dist)) as gid_8_dist, ROUND(AVG(geo_id_8_tickets)) as gid_8_tckts, 
ROUND(AVG(geo_id_9_dist)) as gid_9_dist, ROUND(AVG(geo_id_9_tickets)) as gid_9_tckts, ROUND(AVG(geo_id_10_dist)) as gid_10_dist, ROUND(AVG(geo_id_10_tickets)) as gid_10_tckts
INTO ward_avg_distance_top25
FROM address_monthly_rank
GROUP BY ward_id, ward_name, parking_ticket_rank_25
ORDER BY ward_id, parking_ticket_rank_25;

SELECT ward_id, ward_name, parking_ticket_rank_50, COUNT(*) as num_addresses, 
SUM(parking_tickets) as total_parking_tickets, ROUND(AVG(parking_tickets)) as avg_parking_tickets, 
SUM(tickets_nearby) as total_tickets_nearby, ROUND(AVG(tickets_nearby)) as avg_tickets_nearby, 
ROUND(AVG(geo_id_1_dist)) as gid_1_dist, ROUND(AVG(geo_id_1_tickets)) as gid_1_tckts, ROUND(AVG(geo_id_2_dist)) as gid_2_dist, ROUND(AVG(geo_id_2_tickets)) as gid_2_tckts, 
ROUND(AVG(geo_id_3_dist)) as gid_3_dist, ROUND(AVG(geo_id_3_tickets)) as gid_3_tckts, ROUND(AVG(geo_id_4_dist)) as gid_4_dist, ROUND(AVG(geo_id_4_tickets)) as gid_4_tckts,
ROUND(AVG(geo_id_5_dist)) as gid_5_dist, ROUND(AVG(geo_id_5_tickets)) as gid_5_tckts, ROUND(AVG(geo_id_6_dist)) as gid_6_dist, ROUND(AVG(geo_id_6_tickets)) as gid_6_tckts, 
ROUND(AVG(geo_id_7_dist)) as gid_7_dist, ROUND(AVG(geo_id_7_tickets)) as gid_7_tckts, ROUND(AVG(geo_id_8_dist)) as gid_8_dist, ROUND(AVG(geo_id_8_tickets)) as gid_8_tckts, 
ROUND(AVG(geo_id_9_dist)) as gid_9_dist, ROUND(AVG(geo_id_9_tickets)) as gid_9_tckts, ROUND(AVG(geo_id_10_dist)) as gid_10_dist, ROUND(AVG(geo_id_10_tickets)) as gid_10_tckts
INTO ward_avg_distance_top50
FROM address_monthly_rank
GROUP BY ward_id, ward_name, parking_ticket_rank_50
ORDER BY ward_id, parking_ticket_rank_50;
