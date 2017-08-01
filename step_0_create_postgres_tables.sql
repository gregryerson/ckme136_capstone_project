-- create database table for all city of toronto addresses

CREATE TABLE address (
    index varchar(50),
    geo_id varchar (50),
    centreline_id varchar (50),
    maintenance_stage varchar(50),
    addr_num varchar(50),
    street_name varchar (255),
    addr_low_num varchar(50),
    low_num_suffix varchar(50),
    addr_hi_num varchar(50),
    hi_num_suffix varchar(50), 
    centreline_side varchar(50), 
    centreline_measure float,
    feature_code varchar(50),
    fcode_descr varchar(250),
    address_class_descr varchar(250),
    place_name varchar(250),
    easting_mtm_nad_projection float,
    northing_mtm_nad_projection float,
    long float,
    lat float,
    object_id varchar(50),
    municipality varchar(75),
    ward_name varchar(250)
);

CREATE INDEX idx_a_geo_id ON address (geo_id);

-- create table fo city of toronto issued parking tickets

CREATE TABLE parking_dataset (
    index varchar(15),
    tag_number_masked varchar(15), 
	date_of_infraction timestamp,
	infraction_code varchar(10),
	infraction_description varchar (250), 
	set_fine_amount float, 
	time_of_infraction varchar(10),
	location1 varchar (250), 
	location2 varchar (250), 
	location3 varchar (250), 
	location4 varchar (250), 
	province varchar (10)
);

CREATE INDEX idx_pd_geo_id ON parking_dataset (geo_id);

-- create feature code name table
SELECT feature_code, fcode_descr
INTO feature_code
FROM address
GROUP BY feature_code, fcode_descr
ORDER BY feature_code;

CREATE INDEX idx_fc_feature_code ON feature_code (feature_code);
