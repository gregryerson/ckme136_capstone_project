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

def update_intersections(db, username, pswd):
    conn = psycopg2.connect(database= db, user= username ,password= pswd)
    cursor = conn.cursor()
    
    cursor.execute("UPDATE parking_ticket_address prk SET long = gps.lng, lat = gps.lat FROM intersections_gps gps WHERE prk.match_intersection IS NOT NULL AND INITCAP(prk.match_intersection) = gps.intersection" )
    
    conn.commit()
    cursor.close()
    
# connect to postgresql database
engine = create_engine ('postgresql://gregaraujo:sqlRocks@localhost:5432/gregaraujo')

# query parking_addresses table for intersections that do not have gps coordinates
intersections = pd.read_sql_query("SELECT INITCAP(match_intersection) as intersection, INITCAP(match_intersection) || ', Toronto, ON' as intersection_city, long as lng, lat, count FROM parking_address2 WHERE match_intersection IS NOT NULL AND lat IS NULL AND long IS NULL ORDER BY count DESC LIMIT 1000;", engine)

intersections_dict = {}
i=0
for value in intersections['intersection_city']:
    intersections_dict[i] = decode_address_to_coordinates(value)
    i+=1

# i = 0
# for values in intersections_df['lat'].head():
#    intersections['lat'][i] = values
#    i+= 1
    

intersections_df = pd.DataFrame(intersections_dict)
intersections_df = intersections_df.transpose()

intersections['lat'] = insert_gps(intersections_df, intersections, 'lat', 0)
intersections['lng'] = insert_gps(intersections_df, intersections, 'lng', 0)

export_postgresql(intersections, 'postgresql://gregaraujo:sqlRocks@localhost:5432/gregaraujo', 'intersections_gps')

update_intersections('gregaraujo', 'gregaraujo', 'SQLrocks')
print ('update intersections table complete!')

