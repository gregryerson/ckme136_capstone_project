import psycopg2
import sys
import urllib, urllib2, json

from googlemaps import Client
from sqlalchemy import create_engine


def decode_address_to_coordinates(address):
        params = {
                'address' : address,
                'sensor' : 'false',
        }  
        url = 'http://maps.google.com/maps/api/geocode/json?' + urllib.urlencode(params)
        response = urllib2.urlopen(url)
        result = json.load(response)
        try:
                return result['results'][0]['geometry']['location']
        except:
                return None

def insert_gps (from_df, to_df, col, i):
    for value in from_df[col]:
        to_df[col][i] = value
        i+= 1
    
    return to_df[col]

# import dataFrame to postgresql
def export_postgresql(df, loc, df_str):
    print 'beginning export'
    engine = create_engine(loc)
    df.to_sql(df_str, engine, if_exists= 'append')
    print 'export complete!'

def update_address(db, username, pswd):
    conn = psycopg2.connect(database= db, user= username ,password= pswd)
    cursor = conn.cursor()
    
    cursor.execute("UPDATE parking_ticket_address prk SET long = gps.lng, lat = gps.lat FROM address_gps gps WHERE prk.match_address IS NOT NULL AND (prk.street_num || ' ' || INITCAP(prk.match_address)) = gps.address" )
    
    conn.commit()
    cursor.close()
    
# connect to postgresql database
engine = create_engine ('postgresql://gregaraujo:sqlRocks@localhost:5432/gregaraujo')

# query parking_addresses table for intersections that do not have gps coordinates
address = pd.read_sql_query("SELECT street_num || ' ' || INITCAP(match_address) as address, street_num || ' ' || INITCAP(match_address) || ', Toronto, ON' as address_city, long as lng, lat, count FROM parking_ticket_address WHERE match_address IS NOT NULL AND lat IS NULL AND long IS NULL ORDER BY count DESC LIMIT 1000;", engine)

address.head()
address_dict = {}

i=0
for value in address['address_city']:
    address_dict[i] = decode_address_to_coordinates(value)
    i+=1

address_df = pd.DataFrame(address_dict)
address_df = address_df.transpose()

address['lat'] = insert_gps(address_df, address, 'lat', 0)
address['lng'] = insert_gps(address_df, address, 'lng', 0)

export_postgresql(address, 'postgresql://gregaraujo:sqlRocks@localhost:5432/gregaraujo', 'address_gps')

update_address('gregaraujo', 'gregaraujo', 'SQLrocks')
print ('update address complete!')

