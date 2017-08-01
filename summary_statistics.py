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

# create data frame for analysis
# parking tickets

# total tickets by ward
total_tickets_ward = pd.read_sql_query("SELECT ward_id, ward_name, SUM(parking_tickets) as parking_tickets \
                                        FROM address_monthly_rank \
                                        GROUP BY ward_id, ward_name;", engine)

total_tickets_ward['percent_total_tickets'] = total_tickets_ward['parking_tickets'] / total_tickets_ward['parking_tickets'].sum()
total_tickets_ward

# number tickets by ward
num_tickets_ward = pd.read_sql_query("SELECT ward_id, ward_name, month, \
                                      SUM(parking_tickets) as parking_tickets \
                                      FROM address_monthly_rank \
                                      GROUP BY ward_id, ward_name, month \
                                      ORDER BY ward_id, month;", engine)


# calculate percentage of tickets by month versus total tickets
num_tickets_ward['percent_total_tickets'] = num_tickets_ward['parking_tickets'] / num_tickets_ward['parking_tickets'].sum()
ax = plt.axes()
ax = sns.heatmap(num_tickets_ward.pivot('ward_id', 'month', 'percent_total_tickets'), ax= ax, linewidths=.5)
ax.set_title('Percentage of Tickets By Ward + Month')
plt.show()

# heatmap suggests that there are fairly consistent patterns throughout the year. 

# does the same addresses get ticketed each month
tickets_by_address = pd.read_sql_query("SELECT municipality, ward_id, ward_name, geo_id, month, SUM(parking_tickets) as parking_tickets \
                                        FROM address_monthly_rank \
                                        GROUP BY municipality, ward_id, ward_name, geo_id, month;", engine)

# convert month number to month name
tickets_by_address['month'] = tickets_by_address['month'].apply(lambda x: calendar.month_abbr[x])

# create new columns for each month. if month = column name then insert parking tickets
tickets_by_address['Jan'] = tickets_by_address['parking_tickets'][tickets_by_address['month'] == 'Jan']
tickets_by_address['Feb'] = tickets_by_address['parking_tickets'][tickets_by_address['month'] == 'Feb']
tickets_by_address['Mar'] = tickets_by_address['parking_tickets'][tickets_by_address['month'] == 'Mar']
tickets_by_address['Apr'] = tickets_by_address['parking_tickets'][tickets_by_address['month'] == 'Apr']
tickets_by_address['May'] = tickets_by_address['parking_tickets'][tickets_by_address['month'] == 'May']
tickets_by_address['Jun'] = tickets_by_address['parking_tickets'][tickets_by_address['month'] == 'Jun']
tickets_by_address['Jul'] = tickets_by_address['parking_tickets'][tickets_by_address['month'] == 'Jul']
tickets_by_address['Aug'] = tickets_by_address['parking_tickets'][tickets_by_address['month'] == 'Aug']
tickets_by_address['Sep'] = tickets_by_address['parking_tickets'][tickets_by_address['month'] == 'Sep']
tickets_by_address['Oct'] = tickets_by_address['parking_tickets'][tickets_by_address['month'] == 'Oct']
tickets_by_address['Nov'] = tickets_by_address['parking_tickets'][tickets_by_address['month'] == 'Nov']
tickets_by_address['Dec'] = tickets_by_address['parking_tickets'][tickets_by_address['month'] == 'Dec']

# fill na
tickets_by_address = tickets_by_address.fillna(0)


tickets_by_address.head()
tickets_by_address[tickets_by_address['Dec']> 1000].head()
tickets_by_address.iloc[1733231]

# calculate which months had a ticket for each address
tickets_by_address['Jan_has_ticket'] = 0
tickets_by_address['Jan_has_ticket'][tickets_by_address['Jan'] > 0] = 1

tickets_by_address['Feb_has_ticket'] = 0
tickets_by_address['Feb_has_ticket'][tickets_by_address['Feb'] > 0] = 1

tickets_by_address['Mar_has_ticket'] = 0
tickets_by_address['Mar_has_ticket'][tickets_by_address['Mar'] > 0] = 1 

tickets_by_address['Apr_has_ticket'] = 0
tickets_by_address['Apr_has_ticket'][tickets_by_address['Apr'] > 0] = 1 

tickets_by_address['May_has_ticket'] = 0
tickets_by_address['May_has_ticket'][tickets_by_address['May'] > 0] = 1 

tickets_by_address['Jun_has_ticket'] = 0
tickets_by_address['Jun_has_ticket'][tickets_by_address['Jun'] > 0] = 1 

tickets_by_address['Jul_has_ticket'] = 0
tickets_by_address['Jul_has_ticket'][tickets_by_address['Jul'] > 0] = 1 

tickets_by_address['Aug_has_ticket'] = 0
tickets_by_address['Aug_has_ticket'][tickets_by_address['Aug'] > 0] = 1 

tickets_by_address['Sep_has_ticket'] = 0
tickets_by_address['Sep_has_ticket'][tickets_by_address['Sep'] > 0] = 1 

tickets_by_address['Oct_has_ticket'] = 0
tickets_by_address['Oct_has_ticket'][tickets_by_address['Oct'] > 0] = 1 

tickets_by_address['Nov_has_ticket'] = 0
tickets_by_address['Nov_has_ticket'][tickets_by_address['Nov'] > 0] = 1 

tickets_by_address['Dec_has_ticket'] = 0
tickets_by_address['Dec_has_ticket'][tickets_by_address['Dec'] > 0] = 1 

tickets_by_address.head()
tickets_by_address.iloc[2]

tickets_by_address_aggr = tickets_by_address.groupby(['ward_id', 'ward_name', 'geo_id'], as_index= False).sum()
tickets_by_address_aggr['num_streets'] = 1
tickets_by_address_aggr.head()

# calculate months for each address that did not have a parking ticket

tickets_by_address_aggr['Jan_no_ticket'] = 0
tickets_by_address_aggr['Jan_no_ticket'] = 1 - tickets_by_address_aggr['Jan_has_ticket']

tickets_by_address_aggr['Feb_no_ticket'] = 0
tickets_by_address_aggr['Feb_no_ticket'] = 1 - tickets_by_address_aggr['Feb_has_ticket']

tickets_by_address_aggr['Mar_no_ticket'] = 0
tickets_by_address_aggr['Mar_no_ticket'] = 1 - tickets_by_address_aggr['Mar_has_ticket']

tickets_by_address_aggr['Apr_no_ticket'] = 0
tickets_by_address_aggr['Apr_no_ticket'] = 1 - tickets_by_address_aggr['Apr_has_ticket']

tickets_by_address_aggr['May_no_ticket'] = 0
tickets_by_address_aggr['May_no_ticket'] = 1 - tickets_by_address_aggr['May_has_ticket']

tickets_by_address_aggr['Jun_no_ticket'] = 0
tickets_by_address_aggr['Jun_no_ticket'] = 1 - tickets_by_address_aggr['Jun_has_ticket']

tickets_by_address_aggr['Jul_no_ticket'] = 0
tickets_by_address_aggr['Jul_no_ticket'] = 1 - tickets_by_address_aggr['Jul_has_ticket']

tickets_by_address_aggr['Aug_no_ticket'] = 0
tickets_by_address_aggr['Aug_no_ticket'] = 1 - tickets_by_address_aggr['Aug_has_ticket']

tickets_by_address_aggr['Sep_no_ticket'] = 0
tickets_by_address_aggr['Sep_no_ticket'] = 1 - tickets_by_address_aggr['Sep_has_ticket']

tickets_by_address_aggr['Oct_no_ticket'] = 0
tickets_by_address_aggr['Oct_no_ticket'] = 1 - tickets_by_address_aggr['Oct_has_ticket']

tickets_by_address_aggr['Nov_no_ticket'] = 0
tickets_by_address_aggr['Nov_no_ticket'] = 1 - tickets_by_address_aggr['Nov_has_ticket']

tickets_by_address_aggr['Dec_no_ticket'] = 0
tickets_by_address_aggr['Dec_no_ticket'] = 1 - tickets_by_address_aggr['Dec_has_ticket']

# calculate total tickets by each address
tickets_by_address_aggr['total_tickets'] = tickets_by_address_aggr['Jan'] + tickets_by_address_aggr['Feb'] \
                                         + tickets_by_address_aggr['Mar'] + tickets_by_address_aggr['Apr'] \
                                         + tickets_by_address_aggr['May'] + tickets_by_address_aggr['Jun'] \
                                         + tickets_by_address_aggr['Jul'] + tickets_by_address_aggr['Aug'] \
                                         + tickets_by_address_aggr['Sep'] + tickets_by_address_aggr['Oct'] \
                                         + tickets_by_address_aggr['Nov'] + tickets_by_address_aggr['Dec']

tickets_by_address_aggr['has_ticket'] = tickets_by_address_aggr['Jan_has_ticket'] + tickets_by_address_aggr['Feb_has_ticket'] \
                                      + tickets_by_address_aggr['Mar_has_ticket'] + tickets_by_address_aggr['Apr_has_ticket'] \
                                      + tickets_by_address_aggr['May_has_ticket'] + tickets_by_address_aggr['Jun_has_ticket'] \
                                      + tickets_by_address_aggr['Jul_has_ticket'] + tickets_by_address_aggr['Aug_has_ticket'] \
                                      + tickets_by_address_aggr['Sep_has_ticket'] + tickets_by_address_aggr['Oct_has_ticket'] \
                                      + tickets_by_address_aggr['Nov_has_ticket'] + tickets_by_address_aggr['Dec_has_ticket']

tickets_by_address_aggr['no_ticket'] = 12 - tickets_by_address_aggr['has_ticket']

tickets_by_address_aggr['has_ticket_0_mth'] = 0
tickets_by_address_aggr['has_ticket_0_mth'][tickets_by_address_aggr['has_ticket'] == 0] = 1 

tickets_by_address_aggr['has_ticket_1_mth'] = 0
tickets_by_address_aggr['has_ticket_1_mth'][tickets_by_address_aggr['has_ticket'] == 1] = 1 

tickets_by_address_aggr['has_ticket_2_mth'] = 0
tickets_by_address_aggr['has_ticket_2_mth'][tickets_by_address_aggr['has_ticket'] == 2] = 1 

tickets_by_address_aggr['has_ticket_3_mth'] = 0
tickets_by_address_aggr['has_ticket_3_mth'][tickets_by_address_aggr['has_ticket'] == 3] = 1 

tickets_by_address_aggr['has_ticket_4_mth'] = 0
tickets_by_address_aggr['has_ticket_4_mth'][tickets_by_address_aggr['has_ticket'] == 4] = 1 

tickets_by_address_aggr['has_ticket_5_mth'] = 0
tickets_by_address_aggr['has_ticket_5_mth'][tickets_by_address_aggr['has_ticket'] == 5] = 1 

tickets_by_address_aggr['has_ticket_6_mth'] = 0
tickets_by_address_aggr['has_ticket_6_mth'][tickets_by_address_aggr['has_ticket'] == 6] = 1 

tickets_by_address_aggr['has_ticket_7_mth'] = 0
tickets_by_address_aggr['has_ticket_7_mth'][tickets_by_address_aggr['has_ticket'] == 7] = 1 

tickets_by_address_aggr['has_ticket_8_mth'] = 0
tickets_by_address_aggr['has_ticket_8_mth'][tickets_by_address_aggr['has_ticket'] == 8] = 1 

tickets_by_address_aggr['has_ticket_9_mth'] = 0
tickets_by_address_aggr['has_ticket_9_mth'][tickets_by_address_aggr['has_ticket'] == 9] = 1 

tickets_by_address_aggr['has_ticket_10_mth'] = 0
tickets_by_address_aggr['has_ticket_10_mth'][tickets_by_address_aggr['has_ticket'] == 10] = 1 

tickets_by_address_aggr['has_ticket_11_mth'] = 0
tickets_by_address_aggr['has_ticket_11_mth'][tickets_by_address_aggr['has_ticket'] == 11] = 1 

tickets_by_address_aggr['has_ticket_12_mth'] = 0
tickets_by_address_aggr['has_ticket_12_mth'][tickets_by_address_aggr['has_ticket'] == 12] = 1 

tickets_by_address_aggr.head()
tickets_by_address_aggr.iloc[0]

# tickets_by_address_aggr.to_csv('tickets_by_address_aggr.csv', header = True)

# calculate tickets by ward
tickets_by_ward = tickets_by_address_aggr.groupby(['ward_id', 'ward_name'], as_index = False).sum()
tickets_by_ward.head()
tickets_by_ward.iloc[0]

tickets_by_ward['Jan_percent_has_ticket'] = tickets_by_ward['Jan_has_ticket'].astype(float) / (tickets_by_ward['Jan_has_ticket'].astype(float) + tickets_by_ward['Jan_no_ticket'].astype(float))
tickets_by_ward['Feb_percent_has_ticket'] = tickets_by_ward['Feb_has_ticket'].astype(float) / (tickets_by_ward['Feb_has_ticket'].astype(float) + tickets_by_ward['Feb_no_ticket'].astype(float))
tickets_by_ward['Mar_percent_has_ticket'] = tickets_by_ward['Mar_has_ticket'].astype(float) / (tickets_by_ward['Mar_has_ticket'].astype(float) + tickets_by_ward['Mar_no_ticket'].astype(float))
tickets_by_ward['Apr_percent_has_ticket'] = tickets_by_ward['Apr_has_ticket'].astype(float) / (tickets_by_ward['Apr_has_ticket'].astype(float) + tickets_by_ward['Apr_no_ticket'].astype(float))
tickets_by_ward['May_percent_has_ticket'] = tickets_by_ward['May_has_ticket'].astype(float) / (tickets_by_ward['May_has_ticket'].astype(float) + tickets_by_ward['May_no_ticket'].astype(float))
tickets_by_ward['Jun_percent_has_ticket'] = tickets_by_ward['Jun_has_ticket'].astype(float) / (tickets_by_ward['Jun_has_ticket'].astype(float) + tickets_by_ward['Jun_no_ticket'].astype(float))
tickets_by_ward['Jul_percent_has_ticket'] = tickets_by_ward['Jul_has_ticket'].astype(float) / (tickets_by_ward['Jul_has_ticket'].astype(float) + tickets_by_ward['Jul_no_ticket'].astype(float))
tickets_by_ward['Aug_percent_has_ticket'] = tickets_by_ward['Aug_has_ticket'].astype(float) / (tickets_by_ward['Aug_has_ticket'].astype(float) + tickets_by_ward['Aug_no_ticket'].astype(float))
tickets_by_ward['Sep_percent_has_ticket'] = tickets_by_ward['Sep_has_ticket'].astype(float) / (tickets_by_ward['Sep_has_ticket'].astype(float) + tickets_by_ward['Sep_no_ticket'].astype(float))
tickets_by_ward['Oct_percent_has_ticket'] = tickets_by_ward['Oct_has_ticket'].astype(float) / (tickets_by_ward['Oct_has_ticket'].astype(float) + tickets_by_ward['Oct_no_ticket'].astype(float))
tickets_by_ward['Nov_percent_has_ticket'] = tickets_by_ward['Nov_has_ticket'].astype(float) / (tickets_by_ward['Nov_has_ticket'].astype(float) + tickets_by_ward['Nov_no_ticket'].astype(float))
tickets_by_ward['Dec_percent_has_ticket'] = tickets_by_ward['Dec_has_ticket'].astype(float) / (tickets_by_ward['Dec_has_ticket'].astype(float) + tickets_by_ward['Dec_no_ticket'].astype(float))
tickets_by_ward['Total_percent_has_ticket'] = tickets_by_ward['has_ticket'].astype(float) / (tickets_by_ward['has_ticket'].astype(float) + tickets_by_ward['no_ticket'].astype(float))

tickets_by_ward['mth_0_percent_has_ticket'] = tickets_by_ward['has_ticket_0_mth'].astype(float) / tickets_by_ward['num_streets']
tickets_by_ward['mth_1_percent_has_ticket'] = tickets_by_ward['has_ticket_1_mth'].astype(float) / tickets_by_ward['num_streets']
tickets_by_ward['mth_2_percent_has_ticket'] = tickets_by_ward['has_ticket_2_mth'].astype(float) / tickets_by_ward['num_streets']
tickets_by_ward['mth_3_percent_has_ticket'] = tickets_by_ward['has_ticket_3_mth'].astype(float) / tickets_by_ward['num_streets']
tickets_by_ward['mth_4_percent_has_ticket'] = tickets_by_ward['has_ticket_4_mth'].astype(float) / tickets_by_ward['num_streets']
tickets_by_ward['mth_5_percent_has_ticket'] = tickets_by_ward['has_ticket_5_mth'].astype(float) / tickets_by_ward['num_streets']
tickets_by_ward['mth_6_percent_has_ticket'] = tickets_by_ward['has_ticket_6_mth'].astype(float) / tickets_by_ward['num_streets']
tickets_by_ward['mth_7_percent_has_ticket'] = tickets_by_ward['has_ticket_7_mth'].astype(float) / tickets_by_ward['num_streets']
tickets_by_ward['mth_8_percent_has_ticket'] = tickets_by_ward['has_ticket_8_mth'].astype(float) / tickets_by_ward['num_streets']
tickets_by_ward['mth_9_percent_has_ticket'] = tickets_by_ward['has_ticket_9_mth'].astype(float) / tickets_by_ward['num_streets']
tickets_by_ward['mth_10_percent_has_ticket'] = tickets_by_ward['has_ticket_10_mth'].astype(float) / tickets_by_ward['num_streets']
tickets_by_ward['mth_11_percent_has_ticket'] = tickets_by_ward['has_ticket_11_mth'].astype(float) / tickets_by_ward['num_streets']
tickets_by_ward['mth_12_percent_has_ticket'] = tickets_by_ward['has_ticket_12_mth'].astype(float) / tickets_by_ward['num_streets']

tickets_by_ward.head()

# identify columns required for heat map graph 
tickets_by_ward_graph_cols = ['ward_id', 'ward_name', 'mth_0_percent_has_ticket', 'mth_1_percent_has_ticket', 'mth_2_percent_has_ticket', \
                              'mth_3_percent_has_ticket', 'mth_4_percent_has_ticket', 'mth_5_percent_has_ticket', 'mth_6_percent_has_ticket', \
                              'mth_7_percent_has_ticket', 'mth_8_percent_has_ticket', 'mth_9_percent_has_ticket', 'mth_10_percent_has_ticket', \
                              'mth_11_percent_has_ticket', 'mth_12_percent_has_ticket']

# create new dataframe
tickets_by_ward_graph = tickets_by_ward[tickets_by_ward_graph_cols]

# rename columns (easier to read on graph)
tickets_by_ward_graph_rename_cols = ['ward_id', 'ward_name', '0', '1', '2', '3', '4', '5', '6', '7', '8', '9', '10', '11', '12']

tickets_by_ward_graph.columns = tickets_by_ward_graph_rename_cols
idx = ['ward_id','ward_name'] # create list of columns that are required to index on for pivot table

# use melt function to convert data into format that heatmap function will ingest
tickets_by_ward_graph = pd.melt(tickets_by_ward_graph, id_vars = idx, var_name = 'Months').sort_values(idx).reset_index(drop= True)
tickets_by_ward_graph = tickets_by_ward_graph.fillna(0) # fill na

# create pivot table for heat map
tickets_by_ward_graph_pivot = tickets_by_ward_graph.pivot('ward_id', 'Months', 'value')

# create list in order to change the order of column headings within pivot table
pivot_column_order = ['0', '1', '2', '3', '4', '5', '6', '7', '8', '9', '10', '11', '12'] 
tickets_by_ward_graph_pivot = tickets_by_ward_graph_pivot.reindex_axis(pivot_column_order, axis = 1) #reorder columns

# create heatmap
ax = plt.axes()
ax = sns.heatmap(tickets_by_ward_graph_pivot, ax= ax, linewidths=.5)
ax.set_title('Number of Months Addresses Within Ward \n Issued Parking Ticket By Ward ID')
plt.show()




