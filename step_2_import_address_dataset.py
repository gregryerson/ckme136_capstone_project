import pandas as pd
from simpledbf import Dbf5

#rename column headings
def rename_columns(df, col_head):
    df.columns = col_head
    
    return df

# import dataFrame to postgresql
def export_postgresql(df, loc, df_str):
    print 'beginning export'
    engine = create_engine(loc)
    df.to_sql(df_str, engine, if_exists= 'append')
    print 'export complete!'

# address points file can be accessed here :
# https://www1.toronto.ca/wps/portal/contentonly?vgnextoid=91415f9cd70bb210VgnVCM1000003dd60f89RCRD&vgnextchannel=7807e03bb8d1e310VgnVCM10000071d60f89RCRD

# import addresses
dbf = Dbf5('ADDRESS_POINT_WGS84.dbf') 

# convert to dataframe
address = dbf.to_dataframe()

# rename columns
rename_cols = ['geo_id', 'centreline_id', 'maintenance_stage', 'addr_num', 'street_name', 'addr_low_num', 'low_num_suffix', \
'addr_hi_num', 'hi_num_suffix', 'centreline_side', 'centreline_measure', 'feature_code', 'fcode_descr', 'address_class_descr', \
'place_name', 'easting_mtm_nad_projection', 'northing_mtm_nad_projection', 'long', 'lat', 'object_id', 'municipality', 'ward_name']

address = rename_columns(address, rename_cols)

# export to postgresql table
export_postgresql(address, 'postgresql://gregaraujo:sqlRocks@localhost:5432/gregaraujo', 'address')
