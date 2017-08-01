from sqlalchemy import create_engine

import gmplot
import matplotlib.pyplot as plt
import psycopg2

# connect to postgresql database
engine = create_engine ('postgresql://gregaraujo:sqlRocks@localhost:5432/gregaraujo')

# query gps coordinates for a specific ward
addr_heat_map = pd.read_sql_query("SELECT lat, long \
                                   FROM parking_dataset \
                                   WHERE ward_id IN (23) \
                                   AND lat IS NOT NULL;", engine)

# query gps coordinates for top N parking tickets issued for ward queried previously
addr_markers = pd.read_sql_query("SELECT lat, long \
                                  FROM parking_dataset_aggr_total_dow_top_10 \
                                  WHERE ward_id IN (23) \
                                  AND lat IS NOT NULL \
                                  GROUP BY lat, long ;", engine)

addr_markers.head()

# use first coordinate from addr_markers to center graph
gmap = gmplot.GoogleMapPlotter(43.756057, -79.407116, 12)

# graph topN gps coordinates using scatterplot
gmap.scatter(addr_markers['lat'], addr_markers['long'], 'r', marker=True)

# use heatmap functionality to plot parking ticket frequencies
gmap.heatmap(addr_heat_map['lat'], addr_heat_map['long'])

# initiate graph
gmap.draw('toronto_heat_map_willowdale_23.html')
