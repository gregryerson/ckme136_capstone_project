from sqlalchemy import create_engine

import matplotlib.pyplot as plt
import numpy as np
import pandas as pd
import psycopg2
import datetime

# load csv 
def load_csv(filename):
    df = pd.read_csv(filename, error_bad_lines= False, header= 0)
    
    return df

# convert string date to datetime
def string_to_date(df, col, date_string):
    df[col] = pd.to_datetime(df[col], format = date_string)
    
    return df[col]

# remove decimal
def remove_decimal(df, col):
    df[col] = df[col].astype('str')
    df[col] = np.where(df[col].str.contains('\d*\.0', regex= True) == True, df[col].str[:-2], df[col])

    return df[col]

# add zeros (original timestamp was not in military time format)
def add_zero (df, col, len):
    df[col] = df[col].str.zfill(len)
    
    return df[col]

# remove rows with NaN values (date_of_infraction)
def remove_nan_rows (df, newdf, col):
    newdf = df[df[col].isnull()]
    df = df[df[col].notnull()]
    
    return newdf, df

# calculate hour 
def calculate_hour (df, newcol, col1, col2):
    df[newcol] = df[col1]
    df[newcol][df[col2].str.len() <= 2] = '0'
    df[newcol][df[col2].str.len() == 3] = df[col2].str[0]
    df[newcol][df[col2].str.len() == 4] = df[col2].str[:2]
    
    return df

# calculate minute
def calculate_minute (df, newcol, col1, col2):
    df[newcol] = df[col1]
    df[newcol][df[col2].str.len() <= 2] = df[col2]
    df[newcol][df[col2].str.len() >= 3] = df[col2].str[2:]

    return df    

# separate date
def separate_date (df, col, col1, col2, col3):
    parking[col1] = parking[col].apply(lambda x:x.strftime('%Y'))
    parking[col2] = parking[col].apply(lambda x:x.strftime('%m'))
    parking[col3] = parking[col].apply(lambda x:x.strftime('%d'))
    
    return df
    
# import dataFrame to postgresql
def export_postgresql(df, loc, df_str):
    print 'beginning export'
    engine = create_engine(loc)
    df.to_sql(df_str, engine, if_exists= 'append')
    print 'export complete!'



# due to file sizes for each parking ticket dataset (approx. 20mb to 475 mb). each dataset was loaded 
# separtately. Note that older files (i.e. Parking_Tags_Data_2013) were in utf-8 format. Based on the 
# file, encoding switched between utf-8 / utf-16
# files : Parking_Tags_data_2008.csv : 2,857,664 records
#		  Parking_Tags_data_2009.csv : 2,578,594 records
#		  Parking_Tags_data_2010.csv : 2,717,378 records
# 		  Parking_Tags_data_2011.csv : 2,802,330 records
#		  Parking_Tags_Data_2012.csv : 2,743,578 records
#		  Parking_Tags_Data_2013.csv : 2,589,813 records
#		  Parking_Tags_Data_2014_1.csv / Parking_Tags_Data_2014_2.csv / Parking_Tags_Data_2014_3.csv / Parking_Tags_Data_2014_4.csv :
#			2,483,396 records 
#		  Parking_Tags_Data_2015_1.csv / Parking_Tags_Data_2015_2.csv / Parking_Tags_Data_2015_3.csv
#			2,166,636 records
# 		  Parking_Tags_Data_2016_1.csv / Parking_Tags_Data_2016_2.csv / Parking_Tags_Data_2016_3.csv / Parking_Tags_Data_2016_4.csv
#			2,253,100
# each parking ticket file can be downloaded at https://www1.toronto.ca/wps/portal/contentonly?vgnextoid=ca20256c54ea4310VgnVCM1000003dd60f89RCRD
parking = pd.read_csv('Parking_Tags_Data_2008.csv', encoding= 'utf-16', error_bad_lines= False)

# records that did not have location2 (the majority of parking ticket addresses were located in this field)
# were removed from the dataset
parking_missing_addr, parking = remove_nan_rows(parking, 'parking_missing_addr', 'location2')

# records that did not include a datetimestamp were removed from the dataset
parking_missing_date, parking = remove_nan_rows(parking, 'parking_missing_date', 'date_of_infraction')
parking_missing_time, parking = remove_nan_rows(parking, 'parking_missing_time', 'time_of_infraction')

# datetime in original dataset (i.e. 20161230) was re-formatted into proper datetime format
parking['date_of_infraction'] = string_to_date(parking, 'date_of_infraction', '%Y%m%d')
parking['time_of_infraction'] = remove_decimal(parking, 'time_of_infraction')
parking['time_infraction_length'] = parking['time_of_infraction'].str.len() # column length time_infraction

# timestamp in original dataset (i.e. 1637 = 4:37 pm) was reformatted into proper time format
parking = calculate_hour(parking, 'hour', 'time_infraction_length', 'time_of_infraction')
parking = calculate_minute(parking, 'minute', 'time_infraction_length', 'time_of_infraction')

parking = separate_date(parking, 'date_of_infraction', 'year', 'month', 'day')

# create datetimestamp
parking['date_time_of_infraction'] = pd.to_datetime(parking[['year', 'month', 'day', 'hour', 'minute']])

# drop unnecessary columns before uploading into postgresql database
drop_cols = ['time_infraction_length', 'hour', 'minute', 'year', 'month', 'day']
parking.drop(drop_cols, axis= 1, inplace= True)

# rearrange column order before upload
rearrange_cols = ['date_time_of_infraction', 'date_of_infraction', 'tag_number_masked', 'infraction_code', \
'infraction_description',  'set_fine_amount', 'time_of_infraction', 'location1', 'location2', 'location3', \
'location4', 'province']

parking = parking[rearrange_cols]

# export dataframe to postgresql
export_postgresql(parking, 'postgresql://gregaraujo:sqlRocks@localhost:5432/gregaraujo', 'parking_dataset')




