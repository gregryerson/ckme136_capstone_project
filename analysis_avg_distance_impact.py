from sqlalchemy import create_engine

import calendar
import matplotlib.pyplot as plt
import matplotlib.ticker as tkr
import numpy as np
import pandas as pd
import psycopg2
import seaborn as sns

plt.style.use('ggplot') # graph style

# connect to postgresql database
engine = create_engine ('postgresql://gregaraujo:sqlRocks@localhost:5432/gregaraujo')

avg_distance_ward = pd.read_sql_query("SELECT ward_id, ward_name, parking_ticket_rank_10, \
                                        total_parking_tickets, avg_parking_tickets, total_tickets_nearby, avg_tickets_nearby, \
                                        gid_1_dist, gid_1_tckts, gid_2_dist, gid_2_tckts, gid_3_dist, gid_3_tckts, \
                                        gid_4_dist, gid_4_tckts, gid_5_dist, gid_5_tckts, gid_6_dist, gid_6_tckts, \
                                        gid_7_dist, gid_7_tckts, gid_8_dist, gid_8_tckts, gid_9_dist, gid_9_tckts, \
                                        gid_10_dist, gid_10_tckts \
                                        FROM ward_avg_distance_top10 \
                                        ORDER BY ward_id, parking_ticket_rank_10;", engine)
avg_distance_ward.head()

# create data frames for each category
# parking_ticket_rank_10 = 0 (addresses with no ticket)
avg_distance_ward_10_0 = avg_distance_ward[avg_distance_ward['parking_ticket_rank_10'] == 0]
avg_distance_ward_10_0[['gid_1_dist', 'gid_2_dist','gid_3_dist', 'gid_4_dist', 'gid_5_dist', 'gid_6_dist', 'gid_7_dist', \
                        'gid_8_dist', 'gid_9_dist', 'gid_10_dist']].plot.box(title = 'Boxplot - Distance From Top 10 Ticketed Addresses By Ward \n Non Ticketed Address')
                        
# parking_ticket_rank_10 = 1 (addresses with ticket, not ranked within top 10)
avg_distance_ward_10_1 = avg_distance_ward[avg_distance_ward['parking_ticket_rank_10'] == 1]
avg_distance_ward_10_1[['gid_1_dist', 'gid_2_dist','gid_3_dist', 'gid_4_dist', 'gid_5_dist', 'gid_6_dist', 'gid_7_dist', \
                        'gid_8_dist', 'gid_9_dist', 'gid_10_dist']].plot.box(title = 'Boxplot - Distance From Top 10 Ticketed Addresses By Ward \n Ticketed Address Outside of Top 10')

# parking_ticket_rank_10 = 10 (addresses with ticket, ranked within top 10)
avg_distance_ward_10_10 = avg_distance_ward[avg_distance_ward['parking_ticket_rank_10'] == 10]
avg_distance_ward_10_10[['gid_1_dist', 'gid_2_dist','gid_3_dist', 'gid_4_dist', 'gid_5_dist', 'gid_6_dist', 'gid_7_dist', \
                        'gid_8_dist', 'gid_9_dist', 'gid_10_dist']].plot.box(title = 'Boxplot - Distance From Top 10 Ticketed Addresses By Ward \n Top 10 Addresses')

avg_distance_ward_10_0['avg_tickets_nearby'].plot.box()

# calculate interquartile range/distance (meters) for topN addresses for each category
# categories: 0 - addresses that did not get ticketed
#             1 - addresses that were ticketed but were not ranked within top 10 for their respective ward
#             10 - addresses that were ticketed and ranked within top 10 for their respective ward
# create lists for each category

gid = ['gid_1_dist', 'gid_2_dist', 'gid_3_dist', 'gid_4_dist', 'gid_5_dist', 'gid_6_dist', 'gid_7_dist', 'gid_8_dist', 'gid_9_dist', \
'gid_10_dist']
gid_range_0 = []
gid_range_1 = []
gid_range_10 = []

for col in gid:
    calculate_range = avg_distance_ward_10_0[col].quantile(0.75) - avg_distance_ward_10_0[col].quantile(0.25)
    gid_range_0.append(calculate_range)

for col in gid:
    calculate_range = avg_distance_ward_10_1[col].quantile(0.75) - avg_distance_ward_10_1[col].quantile(0.25)
    gid_range_1.append(calculate_range)

for col in gid:
    calculate_range = avg_distance_ward_10_10[col].quantile(0.75) - avg_distance_ward_10_10[col].quantile(0.25)
    gid_range_10.append(calculate_range)

# combine lists into dataframe

avg_dist_quartile_range = pd.DataFrame({'geo_id': gid, 
                                        'no_ticket': gid_range_0, 
                                        'ticket_outside_top_10': gid_range_1, 
                                        'ticket_within_top_10': gid_range_10})

avg_dist_quartile_range

# interquartile ranges between no_ticket/ticket_outside_top_10/ticket_within_top_10 are minimal between top N. 
# this could possibly suggest that distance from most ticketed parking spots does not have an impact on 
# calculating the probability of receiving a ticket. 
